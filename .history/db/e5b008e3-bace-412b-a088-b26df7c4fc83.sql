select
    t.*
    ,ss.name
from tmpale.tmp_ph_1_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    *
    ,ss.name
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    t.count_num > 2;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,ss.name
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    t.count_num > 2;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name 网点
    ,t.month_d 月份
    ,sum(t.count_num)/count(distinct t.staff_info) 网点平均访问次数
    ,count(distinct t.staff_info) 访问员工数
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    t.count_num > 2
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name 网点
    ,t.month_d 月份
    ,sum(t.count_num) 总访问次数
    ,sum(if(ss.category in (1,10), t.count_num, 0 ))/sum(t.count_num) SP_BDC占比
    ,sum(if(ss.category in (8,12), t.count_num, 0 ))/sum(t.count_num) hub占比
#     ,sum(t.count_num)/count(distinct t.staff_info) 网点平均访问次数
#     ,count(distinct t.staff_info) 访问员工数
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    t.count_num > 2
    and ss.category in (8,12)
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name 网点
    ,t.month_d 月份
    ,sum(t.count_num) 总访问次数
    ,sum(if(ss.category in (1,10), t.count_num, 0 ))/sum(t.count_num) SP_BDC占比
    ,sum(if(ss.category in (8,12), t.count_num, 0 ))/sum(t.count_num) hub占比
#     ,sum(t.count_num)/count(distinct t.staff_info) 网点平均访问次数
#     ,count(distinct t.staff_info) 访问员工数
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    t.count_num > 2
#     and ss.category in (8,12)
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    t.month_d 月份
    ,sum(t.count_num) 总访问次数
    ,sum(if(ss.category in (1,10), t.count_num, 0 ))/sum(t.count_num) SP_BDC占比
    ,sum(if(ss.category in (8,12), t.count_num, 0 ))/sum(t.count_num) hub占比
#     ,sum(t.count_num)/count(distinct t.staff_info) 网点平均访问次数
#     ,count(distinct t.staff_info) 访问员工数
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    t.count_num > 2
#     and ss.category in (8,12)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    t.month_d 月份
#     ,sum(t.count_num) 总访问次数
#     ,sum(if(ss.category in (1,10), t.count_num, 0 ))/sum(t.count_num) SP_BDC占比
#     ,sum(if(ss.category in (8,12), t.count_num, 0 ))/sum(t.count_num) hub占比
     ,ss.name
    ,sum(t.count_num)/count(distinct t.staff_info) 网点每人平均访问次数
    ,count(distinct t.staff_info) 访问员工数
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    t.count_num > 2
    and ss.category in (8,12)
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,ss.name
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    t.count_num > 2
    and ss.category in (8,12)
    and ss.name = '11 PN5-HUB_Santa Rosa'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,ss.name
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    ss.category in (8,12)
    and ss.name = '11 PN5-HUB_Santa Rosa'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,ss.name
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    ss.category in (8,12)
    and ss.name = '11 PN5-HUB_Santa Rosa';
;-- -. . -..- - / . -. - .-. -.--
select
    t.staff_info
    ,t.month_d
    ,ss.name
    ,sum(t.count_num)
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    ss.category in (8,12)
    and ss.name = '11 PN5-HUB_Santa Rosa'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    t.staff_info
    ,t.month_d
    ,ss.name
    ,sum(t.count_num)
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    ss.category in (8,12)
    and ss.name = '11 PN5-HUB_Santa Rosa'
    and t.count_num > 2
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    t.month_d 月份
#     ,sum(t.count_num) 总访问次数
#     ,sum(if(ss.category in (1,10), t.count_num, 0 ))/sum(t.count_num) SP_BDC占比
#     ,sum(if(ss.category in (8,12), t.count_num, 0 ))/sum(t.count_num) hub占比
     ,ss.name
    ,sum(t.count_num)/count(distinct t.staff_info) 网点每人平均访问次数
    ,sum(t.count_num) 总访问
    ,count(distinct t.staff_info) 访问员工数
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    t.count_num > 2
    and ss.category in (8,12)
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    t.staff_info
    ,t.month_d
    ,ss.name
    ,sum(t.count_num)
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    ss.category in (8,12)
    and ss.name = '11 PN5-HUB_Santa Rosa'
    and t.count_num > 2
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
    ,b.总访问_认领
    ,b.网点每人平均访问次数_认领
    ,b.访问员工数_认领
from
    (
        select
            t.month_d
            ,ss.name
            ,sum(t.count_num)/count(distinct t.staff_info) 网点每人平均访问次数_hub
            ,sum(t.count_num) 总访问_hub
            ,count(distinct t.staff_info) 访问员工数_hub
        from tmpale.tmp_ph_hub_0318 t
        left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
        left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
        left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
        where
            ss.category in (8,12)
            and ss.name = '11 PN5-HUB_Santa Rosa'
            and t.count_num > 2
        group by 1,2
    ) a
left join
    (
         select
            t.month_d
            ,ss.name
            ,sum(t._col1)/count(distinct t._col1) 网点每人平均访问次数_认领
            ,sum(t._col1) 总访问_认领
            ,count(distinct t.c_sid_ms) 访问员工数_认领
        from tmpale.tmp_ph_renlin_0318  t
        left join ph_bi.hr_staff_info hsi on t.c_sid_ms = hsi.staff_info_id
        left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
        left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
        where
            ss.category in (8,12)
            and ss.name = '11 PN5-HUB_Santa Rosa'
            and t._col1 > 2
        group by 1,2
    )  b on a.month_d = b.month_d and a.name = b.name;
;-- -. . -..- - / . -. - .-. -.--
select
    t.month_d 月份
    ,ss.name 网点
    ,t.staff_info
    ,t.count_num 次数
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    t.count_num > 10;
;-- -. . -..- - / . -. - .-. -.--
select
    t.month_d 月份
    ,ss.name 网点
    ,t.staff_info
    ,t.count_num 次数
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    t.count_num > 10
    and ss.id is not null;
;-- -. . -..- - / . -. - .-. -.--
select
    t.month_d 月份
    ,ss.name 网点
    ,t.c_sid_ms
    ,t._col1 次数
from tmpale.tmp_ph_renlin_0318 t
left join ph_bi.hr_staff_info hsi on t.c_sid_ms = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    t._col1 > 10
    and ss.id is not null;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
    ,b.总访问_认领
    ,b.网点每人平均访问次数_认领
    ,b.访问员工数_认领
from
    (
        select
            t.month_d
            ,ss.name
            ,sum(t.count_num)/count(distinct t.staff_info) 网点每人平均访问次数_hub
            ,sum(t.count_num) 总访问_hub
            ,count(distinct t.staff_info) 访问员工数_hub
        from tmpale.tmp_ph_hub_0318 t
        left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
        left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
#         left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
        where
            ss.category in (8,12)
#             and ss.name = '11 PN5-HUB_Santa Rosa'
            and t.count_num > 2
        group by 1,2
    ) a
left join
    (
         select
            t.month_d
            ,ss.name
            ,sum(t._col1)/count(distinct t._col1) 网点每人平均访问次数_认领
            ,sum(t._col1) 总访问_认领
            ,count(distinct t.c_sid_ms) 访问员工数_认领
        from tmpale.tmp_ph_renlin_0318  t
        left join ph_bi.hr_staff_info hsi on t.c_sid_ms = hsi.staff_info_id
        left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
#         left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
        where
            ss.category in (8,12)
#             and ss.name = '11 PN5-HUB_Santa Rosa'
            and t._col1 > 2
        group by 1,2
    )  b on a.month_d = b.month_d and a.name = b.name;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,case pi.returned
        when 0 then '正向'
        when 1 then '逆向'
    end 包裹类型
    ,pr.route_action
    ,plt.staff
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_0321 t on t.pno = pi.pno
left join
    (
        select
            pr.pno
            ,pr.route_action
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
    ) plt on plt.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
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
    ,plt.staff
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_0321 t on t.pno = pi.pno
left join
    (
        select
            pr.pno
            ,pr.route_action
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
    ) plt on plt.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
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
    ) ss on ss.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
select date_format(now(), '%H:%i:%s');
;-- -. . -..- - / . -. - .-. -.--
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
    ) ss on ss.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
with lost as
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on pr.pno = t.pno
        where
            pr.route_action = 'DIFFICULTY_HANDOVER'
            and json_extract(pr.extra_value, '$.markerCategory') = 22 -- 丢失
    )
select
    t.pno
    ,lost.staff_info_id 'ID that submitted Lost'
    ,aft.route_action 'Route after Lost was reported'
    ,convert_tz(aft.routed_at, '+00:00', '+08:00') 'Route after Lost was reported - Time'
    ,convert_tz(lost.routed_at, '+00:00', '+08:00') 'Time lost was reported'
    ,bef.route_action
from tmpale.tmp_ph_pno_0321 t
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join tmpale.tmp_ph_pno_0321 t on plt.pno = t.pno and plt.source = 3
        group by 1
    ) c on c.pno = t.pno
left join lost on lost.pno = t.pno
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on pr.pno = t.pno
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at > lost.routed_at
    ) aft on aft.pno = t.pno and aft.rn = 1
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on pr.pno = t.pno
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at < lost.routed_at
    ) bef on bef.pno = t.pno and bef.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
with lost as
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on pr.pno = t.pno
        where
            pr.route_action = 'DIFFICULTY_HANDOVER'
            and json_extract(pr.extra_value, '$.markerCategory') = 22 -- 丢失
    )
select
    t.pno
    ,case aft.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then ' to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 'Route after Lost was reported'
    ,lost.staff_info_id 'ID that submitted Lost'
    ,convert_tz(aft.routed_at, '+00:00', '+08:00') 'Route after Lost was reported - Time'
    ,convert_tz(lost.routed_at, '+00:00', '+08:00') 'Time lost was reported'
    ,case bef.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then 'to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 'Route before reporting Lost'
from tmpale.tmp_ph_pno_0321 t
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join tmpale.tmp_ph_pno_0321 t on plt.pno = t.pno and plt.source = 3
        group by 1
    ) c on c.pno = t.pno
left join lost on lost.pno = t.pno
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on pr.pno = t.pno
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at > lost.routed_at
    ) aft on aft.pno = t.pno and aft.rn = 1
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on pr.pno = t.pno
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at < lost.routed_at
    ) bef on bef.pno = t.pno and bef.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
with lost as
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on pr.pno = t.pno
        where
            pr.route_action = 'DIFFICULTY_HANDOVER'
            and json_extract(pr.extra_value, '$.markerCategory') = 22 -- 丢失
    )
select
    t.pno
    ,if(c.pno is null , 'NO', 'YES') 'Source C'
    ,case aft.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then ' to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 'Route after Lost was reported'
    ,lost.staff_info_id 'ID that submitted Lost'
    ,convert_tz(aft.routed_at, '+00:00', '+08:00') 'Route after Lost was reported - Time'
    ,convert_tz(lost.routed_at, '+00:00', '+08:00') 'Time lost was reported'
    ,case bef.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then 'to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 'Route before reporting Lost'
from tmpale.tmp_ph_pno_0321 t
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join tmpale.tmp_ph_pno_0321 t on plt.pno = t.pno and plt.source = 3
        group by 1
    ) c on c.pno = t.pno
left join lost on lost.pno = t.pno
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on pr.pno = t.pno
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at > lost.routed_at
    ) aft on aft.pno = t.pno and aft.rn = 1
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_0321 t on pr.pno = t.pno
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at < lost.routed_at
    ) bef on bef.pno = t.pno and bef.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
    ,b.总访问_认领
    ,b.网点每人平均访问次数_认领
    ,b.访问员工数_认领
from
    (
        select
            t.month_d
            ,ss.name
            ,sum(t.count_num)/count(distinct t.staff_info) 网点每人平均访问次数_hub
            ,sum(t.count_num) 总访问_hub
            ,count(distinct t.staff_info) 访问员工数_hub
        from tmpale.tmp_ph_hub_0318 t
        left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
        left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
#         left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
        where
            ss.category in (8,12)
#             and ss.name = '11 PN5-HUB_Santa Rosa'
            and t.count_num > 2
        group by 1,2
    ) a
left join
    (
         select
            t.month_d
            ,ss.name
            ,sum(t._col1)/count(distinct t. c_sid_ms) 网点每人平均访问次数_认领
            ,sum(t._col1) 总访问_认领
            ,count(distinct t. c_sid_ms) 访问员工数_认领
        from tmpale.tmp_ph_renlin_0318  t
        left join ph_bi.hr_staff_info hsi on t.c_sid_ms = hsi.staff_info_id
        left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
#         left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
        where
            ss.category in (8,12)
#             and ss.name = '11 PN5-HUB_Santa Rosa'
            and t._col1 > 2
        group by 1,2
    )  b on a.month_d = b.month_d and a.name = b.name;
;-- -. . -..- - / . -. - .-. -.--
select
    a.staff_info_id*
from
    (

        select
            a.*
        from
            (
                select
                    mw.staff_info_id
                    ,mw.id
                    ,mw.created_at
                    ,count(mw.id) over (partition by mw.staff_info_id) js_num
                    ,row_number() over (partition by mw.staff_info_id order by mw.created_at desc) rn
                from ph_backyard.message_warning mw
            ) a
        where
            a.rn = 1
    ) a
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = a.staff_info_id
where
    a.js_num >= 3
    and a.created_at < '2023-01-01'
    and hsi.state = 1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.staff_info_id
from
    (

        select
            a.*
        from
            (
                select
                    mw.staff_info_id
                    ,mw.id
                    ,mw.created_at
                    ,count(mw.id) over (partition by mw.staff_info_id) js_num
                    ,row_number() over (partition by mw.staff_info_id order by mw.created_at desc) rn
                from ph_backyard.message_warning mw
            ) a
        where
            a.rn = 1
    ) a
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = a.staff_info_id
where
    a.js_num >= 3
    and a.created_at < '2023-01-01'
    and hsi.state = 1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
     pr.`store_id`
    ,pr.pno

from `ph_staging`.`parcel_route` pr
left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
left join ph_staging.sys_store ss on ss.id = pr.store_id
where
    pr.`route_action` in ('SHIPMENT_WAREHOUSE_SCAN')
    and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y%m%d')=date_sub(curdate(),interval 1 day)
    and pi.`exhibition_weight`<=3000
    and (pi.`exhibition_length` +pi.`exhibition_width` +pi.`exhibition_height`)<=60
    and pi.`exhibition_length` <=30
    and pi.`exhibition_width` <=30
    and pi.`exhibition_height` <=30
    and ss.category in (8,12)
    and ss.state = 1
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
     pr.`store_id` 网点ID
    ,ss.name 网点
    ,pr.pno 包裹

from `ph_staging`.`parcel_route` pr
left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
left join ph_staging.sys_store ss on ss.id = pr.store_id
where
    pr.`route_action` in ('SHIPMENT_WAREHOUSE_SCAN')
    and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y%m%d')=date_sub(curdate(),interval 1 day)
    and pi.`exhibition_weight`<=3000
    and (pi.`exhibition_length` +pi.`exhibition_width` +pi.`exhibition_height`)<=60
    and pi.`exhibition_length` <=30
    and pi.`exhibition_width` <=30
    and pi.`exhibition_height` <=30
    and ss.category in (8,12)
    and ss.state = 1
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
     pr.`store_id` 网点ID
    ,ss.name 网点
    ,pr.pno 包裹

from `ph_staging`.`parcel_route` pr
left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
left join ph_staging.sys_store ss on ss.id = pr.store_id
where
    pr.`route_action` in ('SHIPMENT_WAREHOUSE_SCAN')
    and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y%m%d')=date_sub(curdate(),interval 1 day)
    and pi.`exhibition_weight`<=3000
    and (pi.`exhibition_length` +pi.`exhibition_width` +pi.`exhibition_height`)<=60
    and pi.`exhibition_length` <=30
    and pi.`exhibition_width` <=30
    and pi.`exhibition_height` <=30
    and ss.category in (8,12)
#     and ss.state = 1
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
     pr.`store_id` 网点ID
    ,ss.name 网点
    ,pr.pno 包裹

from `ph_staging`.`parcel_route` pr
left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
left join ph_staging.sys_store ss on ss.id = pr.store_id
where
    pr.`route_action` in ('SHIPMENT_WAREHOUSE_SCAN')
    and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y%m%d')=date_sub(curdate(),interval 1 day)
    and pi.`exhibition_weight`<=3000
    and (pi.`exhibition_length` +pi.`exhibition_width` +pi.`exhibition_height`)<=60
    and pi.`exhibition_length` <=30
    and pi.`exhibition_width` <=30
    and pi.`exhibition_height` <=30
#     and ss.category in (8,12)
#     and ss.state = 1
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select date_sub(curdate(),interval 1 day);
;-- -. . -..- - / . -. - .-. -.--
select
     pr.`store_id` 网点ID
    ,ss.name 网点
    ,pr.pno 包裹

from `ph_staging`.`parcel_route` pr
left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
left join ph_staging.sys_store ss on ss.id = pr.store_id
where
    pr.`route_action` in ('SHIPMENT_WAREHOUSE_SCAN')
    and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y-%m-%d')=date_sub(curdate(),interval 1 day)
    and pi.`exhibition_weight`<=3000
    and (pi.`exhibition_length` +pi.`exhibition_width` +pi.`exhibition_height`)<=60
    and pi.`exhibition_length` <=30
    and pi.`exhibition_width` <=30
    and pi.`exhibition_height` <=30
#     and ss.category in (8,12)
#     and ss.state = 1
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
    mw.staff_info_id
    ,mw.id
    ,mw.type_code
from ph_backyard.message_warning mw
where
    mw.staff_info_id in ('119872', '124880', '119279', '119022', '118822', '118925', '120282', '130832', '120267', '123336', '119617', '146865');
;-- -. . -..- - / . -. - .-. -.--
select
    mw.staff_info_id
    ,mw.id
    ,mw.type_code
    ,mw.date_at
from ph_backyard.message_warning mw
where
    mw.staff_info_id in ('119872', '124880', '119279', '119022', '118822', '118925', '120282', '130832', '120267', '123336', '119617', '146865');
;-- -. . -..- - / . -. - .-. -.--
select
    mw.staff_info_id
    ,mw.id
    ,mw.type_code
    ,mw.date_at
    ,mw.created_at
from ph_backyard.message_warning mw
where
    mw.staff_info_id in ('119872', '124880', '119279', '119022', '118822', '118925', '120282', '130832', '120267', '123336', '119617', '146865');
;-- -. . -..- - / . -. - .-. -.--
select
    mw.staff_info_id 员工ID
    ,mw.id 警告信ID
    ,mw.created_at 警告信创建时间
    ,mw.is_delete 是否删除
    ,case mw.type_code
        when 'warning_1'  then '迟到早退'
        when 'warning_29' then '贪污包裹'
        when 'warning_30' then '偷盗公司财物'
        when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 'warning_9'  then '腐败/滥用职权'
        when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 'warning_5'  then '持有或吸食毒品'
        when 'warning_4'  then '工作时间或工作地点饮酒'
        when 'warning_10' then '玩忽职守'
        when 'warning_2'  then '无故连续旷工3天'
        when 'warning_3'  then '贪污'
        when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
        when 'warning_7'  then '通过社会媒体污蔑公司'
        when 'warning_27' then '工作效率未达到公司的标准(KPI)'
        when 'warning_26' then 'Fake POD'
        when 'warning_25' then 'Fake Status'
        when 'warning_24' then '不接受或不配合公司的调查'
        when 'warning_23' then '损害公司名誉'
        when 'warning_22' then '失职'
        when 'warning_28' then '贪污钱'
        when 'warning_21' then '煽动/挑衅/损害公司利益'
        when 'warning_20' then '谎报里程'
        when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
        when 'warning_19' then '未按照网点规定的时间回款'
        when 'warning_17' then '伪造证件'
        when 'warning_12' then '未告知上级或无故旷工'
        when 'warning_13' then '上级没有同意请假'
        when 'warning_14' then '没有通过系统请假'
        when 'warning_15' then '未按时上下班'
        when 'warning_16' then '不配合公司的吸毒检查'
        when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
        else mw.`type_code`
    end as '警告原因'
from ph_backyard.message_warning mw
where
    mw.staff_info_id in ('119872', '124880', '119279', '119022', '118822', '118925', '120282', '130832', '120267', '123336', '119617', '146865');
;-- -. . -..- - / . -. - .-. -.--
select
    a.date_d
    ,a.pr_num 派件量
    ,b.diff_num 疑难量
    ,b.diff_num/a.pr_num 疑难件率
from
    (
        select
            date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
            ,count(distinct pr.pno) pr_num
        from ph_staging.parcel_route pr
        where
            pr.routed_at > '2023-02-13 16:00:00'
            and pr.routed_at < '2023-03-20 16:00:00'
            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN','DELIVERY_CONFIRM')
        group by 1
    ) a
left join
    (
        select
            date(convert_tz(di.created_at, '+00:00', '+08:00')) date_d
            ,count(distinct di.pno) diff_num
        from ph_staging.diff_info di
        where
            di.created_at >= '2023-02-13 16:00:00'
            and di.created_at < '2023-03-20 16:00:00'
        group by 1
    ) b on a.date_d = b.date_d;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(a.created_at, '+00:00', '+08:00')) date_d
    ,case a.diff_marker_category
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
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
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
    end reason
    ,count(distinct a.pno) diff_num
    ,count(distinct a.pno) over (partition by date(convert_tz(a.created_at, '+00:00', '+08:00'))) 总计
from
    (
        select
            di.diff_marker_category
            ,di.created_at
            ,di.pno
        from ph_staging.diff_info di
        where
            di.created_at >= '2023-02-13 16:00:00'
            and di.created_at < '2023-03-20 16:00:00'

        union all

        select
            ppd.diff_marker_category
            ,ppd.created_at
            ,ppd.pno
        from ph_staging.parcel_problem_detail ppd
        where
            ppd.created_at >= '2023-02-13 16:00:00'
            and ppd.created_at < '2023-03-20 16:00:00'
            and ppd.parcel_problem_type_category = 2 -- 留仓
    ) a;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(a.created_at, '+00:00', '+08:00')) date_d
    ,case a.diff_marker_category
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
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
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
    end reason
    ,count(distinct a.pno) diff_num
    ,count( a.pno) over (partition by date(convert_tz(a.created_at, '+00:00', '+08:00'))) 总计
from
    (
        select
            di.diff_marker_category
            ,di.created_at
            ,di.pno
        from ph_staging.diff_info di
        where
            di.created_at >= '2023-02-13 16:00:00'
            and di.created_at < '2023-03-20 16:00:00'

        union all

        select
            ppd.diff_marker_category
            ,ppd.created_at
            ,ppd.pno
        from ph_staging.parcel_problem_detail ppd
        where
            ppd.created_at >= '2023-02-13 16:00:00'
            and ppd.created_at < '2023-03-20 16:00:00'
            and ppd.parcel_problem_type_category = 2 -- 留仓
    ) a;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(a.created_at, '+00:00', '+08:00')) date_d
    ,case a.diff_marker_category
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
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
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
    end reason
    ,count(distinct a.pno) diff_num
    ,count( a.pno) over (partition by date(convert_tz(a.created_at, '+00:00', '+08:00'))) 总计
from
    (
        select
            di.diff_marker_category
            ,di.created_at
            ,di.pno
        from ph_staging.diff_info di
        where
            di.created_at >= '2023-02-13 16:00:00'
            and di.created_at < '2023-03-20 16:00:00'

        union all

        select
            ppd.diff_marker_category
            ,ppd.created_at
            ,ppd.pno
        from ph_staging.parcel_problem_detail ppd
        where
            ppd.created_at >= '2023-02-13 16:00:00'
            and ppd.created_at < '2023-03-20 16:00:00'
            and ppd.parcel_problem_type_category = 2 -- 留仓
    ) a
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(a.created_at, '+00:00', '+08:00')) date_d
    ,case a.diff_marker_category
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
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
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
    end reason
    ,count(distinct a.pno) diff_num
#     ,count( a.pno) over (partition by date(convert_tz(a.created_at, '+00:00', '+08:00'))) 总计
from
    (
        select
            di.diff_marker_category
            ,di.created_at
            ,di.pno
        from ph_staging.diff_info di
        where
            di.created_at >= '2023-02-13 16:00:00'
            and di.created_at < '2023-03-20 16:00:00'

        union all

        select
            ppd.diff_marker_category
            ,ppd.created_at
            ,ppd.pno
        from ph_staging.parcel_problem_detail ppd
        where
            ppd.created_at >= '2023-02-13 16:00:00'
            and ppd.created_at < '2023-03-20 16:00:00'
            and ppd.parcel_problem_type_category = 2 -- 留仓
    ) a
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(a.created_at, '+00:00', '+08:00')) date_d
    ,case a.diff_marker_category
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
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
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
    end reason
    ,count(distinct a.pno) diff_num
#     ,count( a.pno) over (partition by date(convert_tz(a.created_at, '+00:00', '+08:00'))) 总计
from
    (
        select
            di.diff_marker_category
            ,di.created_at
            ,di.pno
        from ph_staging.diff_info di
        where
            di.created_at >= '2023-02-13 16:00:00'
            and di.created_at < '2023-03-20 16:00:00'

        union all

        select
            ppd.diff_marker_category
            ,ppd.created_at
            ,ppd.pno
        from ph_staging.parcel_problem_detail ppd
        where
            ppd.created_at >= '2023-02-13 16:00:00'
            and ppd.created_at < '2023-03-20 16:00:00'
            and ppd.parcel_problem_type_category = 2 -- 留仓
    ) a
group by 1,2
with rollup;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
    ,sum(a.diff_num) over (partition by a.date_d) date_total
from
    (
        select
            date(convert_tz(a.created_at, '+00:00', '+08:00')) date_d
            ,case a.diff_marker_category
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
                when 50 then '客户取消寄件'
                when 51 then '信息录入错误'
                when 52 then '客户取消寄件'
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
            end reason
            ,count(distinct a.pno) diff_num
        from
            (
                select
                    di.diff_marker_category
                    ,di.created_at
                    ,di.pno
                from ph_staging.diff_info di
                where
                    di.created_at >= '2023-02-13 16:00:00'
                    and di.created_at < '2023-03-20 16:00:00'

                union all

                select
                    ppd.diff_marker_category
                    ,ppd.created_at
                    ,ppd.pno
                from ph_staging.parcel_problem_detail ppd
                where
                    ppd.created_at >= '2023-02-13 16:00:00'
                    and ppd.created_at < '2023-03-20 16:00:00'
                    and ppd.parcel_problem_type_category = 2 -- 留仓
            ) a
        group by 1,2
    ) a;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
    ,sum(a.diff_num) total
from
    (
        select
            case a.diff_marker_category
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
                when 50 then '客户取消寄件'
                when 51 then '信息录入错误'
                when 52 then '客户取消寄件'
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
            end reason
            ,count(distinct a.pno) diff_num
        from
            (
                select
                    di.diff_marker_category
                    ,di.created_at
                    ,di.pno
                from ph_staging.diff_info di
                where
                    di.created_at >= '2023-02-13 16:00:00'
                    and di.created_at < '2023-03-20 16:00:00'

                union all

                select
                    ppd.diff_marker_category
                    ,ppd.created_at
                    ,ppd.pno
                from ph_staging.parcel_problem_detail ppd
                where
                    ppd.created_at >= '2023-02-13 16:00:00'
                    and ppd.created_at < '2023-03-20 16:00:00'
                    and ppd.parcel_problem_type_category = 2 -- 留仓
            ) a
        group by 1
    ) a
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
    ,sum(a.diff_num) over () total
from
    (
        select
            case a.diff_marker_category
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
                when 50 then '客户取消寄件'
                when 51 then '信息录入错误'
                when 52 then '客户取消寄件'
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
            end reason
            ,count(distinct a.pno) diff_num
        from
            (
                select
                    di.diff_marker_category
                    ,di.created_at
                    ,di.pno
                from ph_staging.diff_info di
                where
                    di.created_at >= '2023-02-13 16:00:00'
                    and di.created_at < '2023-03-20 16:00:00'

                union all

                select
                    ppd.diff_marker_category
                    ,ppd.created_at
                    ,ppd.pno
                from ph_staging.parcel_problem_detail ppd
                where
                    ppd.created_at >= '2023-02-13 16:00:00'
                    and ppd.created_at < '2023-03-20 16:00:00'
                    and ppd.parcel_problem_type_category = 2 -- 留仓
            ) a
        group by 1
    ) a;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,count(distinct pi.pno) 揽收量
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null)) COD量
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null))/count(distinct pi.pno)  揽收COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct di.pno)/count(distinct pi.pno) 总疑难件率
from ph_staging.parcel_info pi
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pi.created_at >= '2023-02-13 16:00:00'
    and pi.created_at < '2023-03-20 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,count(distinct pi.pno) 揽收量
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null)) COD量
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null))/count(distinct pi.pno)  揽收COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct di.pno)/count(distinct pi.pno) 总疑难件率
from ph_staging.parcel_info pi
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pi.created_at >= '2023-02-13 16:00:00'
    and pi.created_at < '2023-03-20 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,count(distinct pi.pno) 揽收量
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null)) COD量
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null))/count(distinct pi.pno)  揽收COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct di.pno)/count(distinct pi.pno) 总疑难件率
from ph_staging.parcel_info pi
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pi.created_at >= '2023-02-13 16:00:00'
    and pi.created_at < '2023-03-20 16:00:00'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,count(distinct pi.pno) 揽收量
    ,count(distinct di.pno) 疑难件量
    ,count(distinct di.pno)/count(distinct pi.pno) COD疑难件率
from ph_staging.parcel_info pi
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pi.created_at >= '2023-02-13 16:00:00'
    and pi.created_at < '2023-03-20 16:00:00'
    and pi.cod_enabled = 1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    kp.id
    ,count(distinct pi.pno) 揽收量
    ,count(if(pi,kp.cod_enabled = 1, pi.pno, null)) 揽收COD量
    ,count(if(pi,kp.cod_enabled = 1, pi.pno, null))/count(distinct pi.pno) 揽收COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null)) COD疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null))/count(distinct di.pno)  疑难件COD占比
    ,count(distinct di.pno)/count(distinct pi.pno) 疑难件率
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null))/count(if(pi,kp.cod_enabled = 1, pi.pno, null)) COD疑难件率
from ph_staging.parcel_info pi
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pi.created_at >= '2023-02-13 16:00:00'
    and pi.created_at < '2023-03-20 16:00:00'
    and kp.id is not null
    and bc.client_id is null
group by 1
order by 5
limit 100;
;-- -. . -..- - / . -. - .-. -.--
select
    kp.id
    ,count(distinct pi.pno) 揽收量
    ,count(if(pi.cod_enabled = 1, pi.pno, null)) 揽收COD量
    ,count(if(pi.cod_enabled = 1, pi.pno, null))/count(distinct pi.pno) 揽收COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null)) COD疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null))/count(distinct di.pno)  疑难件COD占比
    ,count(distinct di.pno)/count(distinct pi.pno) 疑难件率
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null))/count(if(pi,kp.cod_enabled = 1, pi.pno, null)) COD疑难件率
from ph_staging.parcel_info pi
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pi.created_at >= '2023-02-13 16:00:00'
    and pi.created_at < '2023-03-20 16:00:00'
    and kp.id is not null
    and bc.client_id is null
group by 1
order by 5
limit 100;
;-- -. . -..- - / . -. - .-. -.--
select
    kp.id
    ,count(distinct pi.pno) 揽收量
    ,count(if(pi.cod_enabled = 1, pi.pno, null)) 揽收COD量
    ,count(if(pi.cod_enabled = 1, pi.pno, null))/count(distinct pi.pno) 揽收COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null)) COD疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null))/count(distinct di.pno)  疑难件COD占比
    ,count(distinct di.pno)/count(distinct pi.pno) 疑难件率
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null))/count(if(pi.cod_enabled = 1, pi.pno, null)) COD疑难件率
from ph_staging.parcel_info pi
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pi.created_at >= '2023-02-13 16:00:00'
    and pi.created_at < '2023-03-20 16:00:00'
    and kp.id is not null
    and bc.client_id is null
group by 1
order by 5
limit 100;
;-- -. . -..- - / . -. - .-. -.--
select
    kp.id
    ,count(distinct pi.pno) 揽收量
    ,count(if(pi.cod_enabled = 1, pi.pno, null)) 揽收COD量
    ,count(if(pi.cod_enabled = 1, pi.pno, null))/count(distinct pi.pno) 揽收COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null)) COD疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null))/count(distinct di.pno)  疑难件COD占比
    ,count(distinct di.pno)/count(distinct pi.pno) 疑难件率
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pi.pno, null))/count(if(pi.cod_enabled = 1, pi.pno, null)) COD疑难件率
from ph_staging.parcel_info pi
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pi.created_at >= '2023-02-13 16:00:00'
    and pi.created_at < '2023-03-20 16:00:00'
    and kp.id is not null
    and bc.client_id is null
group by 1
order by 5 desc
limit 100;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,count(distinct pr.pno) 交接量
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null)) COD量
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null))/count(distinct pi.pno)  揽收COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct di.pno)/count(distinct pi.pno) 总疑难件率
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pr.routed_at >= '2023-02-13 16:00:00'
    and pr.routed_at < '2023-03-20 16:00:00'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,count(distinct pr.pno) 交接量
    ,count(distinct di.pno) 疑难件量
    ,count(distinct di.pno)/count(distinct pi.pno) COD疑难件率
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pr.routed_at >= '2023-02-13 16:00:00'
    and pr.routed_at < '2023-03-20 16:00:00'
    and pi.cod_enabled = 1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    kp.id
    ,count(distinct pr.pno) 交接量
    ,count(if(pi.cod_enabled = 1, pr.pno, null)) 交接COD量
    ,count(if(pi.cod_enabled = 1, pr.pno, null))/count(distinct pi.pno) 交接COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pr.pno, null)) COD疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pr.pno, null))/count(distinct di.pno)  疑难件COD占比
    ,count(distinct di.pno)/count(distinct pr.pno) 疑难件率
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pr.pno, null))/count(if(pi.cod_enabled = 1, pr.pno, null)) COD疑难件率
from ph_staging.parcel_route pr
left join  ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pr.routed_at >= '2023-02-13 16:00:00'
    and pr.routed_at < '2023-03-20 16:00:00'
    and kp.id is not null
    and bc.client_id is null
group by 1
order by 5 desc
limit 100;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,count(distinct pr.pno) 交接量
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null)) COD量
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null))/count(distinct pi.pno)  揽收COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct di.pno)/count(distinct pi.pno) 总疑难件率
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pr.routed_at >= '2023-02-13 16:00:00'
    and pr.routed_at < '2023-03-20 16:00:00'
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,count(distinct pr.pno) 交接量
    ,count(distinct di.pno) 疑难件量
    ,count(distinct di.pno)/count(distinct pi.pno) COD疑难件率
from ph_staging.parcel_route pr
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pr.routed_at >= '2023-02-13 16:00:00'
    and pr.routed_at < '2023-03-20 16:00:00'
    and pi.cod_enabled = 1
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    kp.id
    ,count(distinct pr.pno) 交接量
    ,count(if(pi.cod_enabled = 1, pr.pno, null)) 交接COD量
    ,count(if(pi.cod_enabled = 1, pr.pno, null))/count(distinct pi.pno) 交接COD占比
    ,count(distinct di.pno) 疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pr.pno, null)) COD疑难件量
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pr.pno, null))/count(distinct di.pno)  疑难件COD占比
    ,count(distinct di.pno)/count(distinct pr.pno) 疑难件率
    ,count(distinct if(pi.cod_enabled = 1 and di.pno is not null , pr.pno, null))/count(if(pi.cod_enabled = 1, pr.pno, null)) COD疑难件率
from ph_staging.parcel_route pr
left join  ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.diff_info di on di.pno = pi.pno
where
    pr.routed_at >= '2023-02-13 16:00:00'
    and pr.routed_at < '2023-03-20 16:00:00'
    and kp.id is not null
    and bc.client_id is null
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
group by 1
order by 5 desc
limit 100;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.pno
    from ph_staging.parcel_route pr
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada','shopee','tiktok')
    where
        pr.routed_at >= '2023-02-13 16:00:00'
        and pr.routed_at < '2023-03-20 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    group by 1
)
select
    case di.diff_marker_category
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
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
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
    end 疑难原因
    ,count(distinct di.pno) 疑难件量
    ,scan.scan_num 交接总量
    ,count(distinct di.pno)/scan.scan_num 疑难件率
    ,scan.cod_num COD交接量
    ,count(distinct if(pi.cod_enabled = 1, di.pno, null)) COD疑难件量
    ,count(distinct if(pi.cod_enabled = 1, di.pno, null))/scan.cod_num COD疑难件率
from t
left join ph_staging.parcel_info pi on pi.pno = t.pno
left join
    (
        select
            di.pno
            ,di.diff_marker_category
        from ph_staging.diff_info di
        join t on di.pno = t.pno
        group by 1,2

        union all

        select
            ppd.pno
            ,ppd.diff_marker_category
        from ph_staging.parcel_problem_detail ppd
        join t on t.pno = ppd.pno
        where
            ppd.parcel_problem_type_category = 2
        group by 1,2
    ) di on di.pno = t.pno
cross join
    (
        select
            count(t.pno) scan_num
            ,count(if(pi.cod_enabled = 1, pi.pno, null)) cod_num
        from t
        left join ph_staging.parcel_info pi on pi.pno = t.pno
    ) scan;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.pno
    from ph_staging.parcel_route pr
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada','shopee','tiktok')
    where
        pr.routed_at >= '2023-02-13 16:00:00'
        and pr.routed_at < '2023-03-20 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    group by 1
)
select
    case di.diff_marker_category
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
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
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
    end 疑难原因
    ,count(distinct di.pno) 疑难件量
    ,scan.scan_num 交接总量
    ,count(distinct di.pno)/scan.scan_num 疑难件率
    ,scan.cod_num COD交接量
    ,count(distinct if(pi.cod_enabled = 1, di.pno, null)) COD疑难件量
    ,count(distinct if(pi.cod_enabled = 1, di.pno, null))/scan.cod_num COD疑难件率
from t
left join ph_staging.parcel_info pi on pi.pno = t.pno
left join
    (
        select
            di.pno
            ,di.diff_marker_category
        from ph_staging.diff_info di
        join t on di.pno = t.pno
        group by 1,2

        union all

        select
            ppd.pno
            ,ppd.diff_marker_category
        from ph_staging.parcel_problem_detail ppd
        join t on t.pno = ppd.pno
        where
            ppd.parcel_problem_type_category = 2
        group by 1,2
    ) di on di.pno = t.pno
cross join
    (
        select
            count(t.pno) scan_num
            ,count(if(pi.cod_enabled = 1, pi.pno, null)) cod_num
        from t
        left join ph_staging.parcel_info pi on pi.pno = t.pno
    ) scan
group by 1,3,5;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        case
            when bc.`client_id` is not null then bc.client_name
            when kp.id is not null and bc.client_id is null then '普通ka'
            when kp.`id` is null then '小c'
        end client_type
        ,pr.pno
    from ph_staging.parcel_route pr
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    left join ph_staging.ka_profile kp on kp.id = pi.client_id
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
    where
        pr.routed_at >= '2023-02-13 16:00:00'
        and pr.routed_at < '2023-03-20 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    group by 1,2
)
select
    t.client_type
    ,case di.diff_marker_category
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
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
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
    end 疑难原因
    ,count(distinct di.pno) 疑难件量
    ,scan.scan_num 交接总量
    ,count(distinct di.pno)/scan.scan_num 疑难件率
    ,scan.cod_num COD交接量
    ,count(distinct if(pi.cod_enabled = 1, di.pno, null)) COD疑难件量
    ,count(distinct if(pi.cod_enabled = 1, di.pno, null))/scan.cod_num COD疑难件率
from t
left join ph_staging.parcel_info pi on pi.pno = t.pno
left join
    (
        select
            di.pno
            ,di.diff_marker_category
        from ph_staging.diff_info di
        join t on di.pno = t.pno
        group by 1,2

        union all

        select
            ppd.pno
            ,ppd.diff_marker_category
        from ph_staging.parcel_problem_detail ppd
        join t on t.pno = ppd.pno
        where
            ppd.parcel_problem_type_category = 2
        group by 1,2
    ) di on di.pno = t.pno
left  join
    (
        select
            t.client_type
            ,count(t.pno) scan_num
            ,count(if(pi.cod_enabled = 1, pi.pno, null)) cod_num
        from t
        left join ph_staging.parcel_info pi on pi.pno = t.pno
        group by 1
    ) scan on scan.client_type = t.client_type
group by 1,2,4,6;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        case
            when bc.`client_id` is not null then bc.client_name
            when kp.id is not null and bc.client_id is null then '普通ka'
            when kp.`id` is null then '小c'
        end client_type
        ,pr.pno
    from ph_staging.parcel_route pr
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    left join ph_staging.ka_profile kp on kp.id = pi.client_id
    left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
    where
        pr.routed_at >= '2023-02-13 16:00:00'
        and pr.routed_at < '2023-03-20 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    group by 1,2
)
select
    t.client_type
    ,case di.diff_marker_category
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
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
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
    end 疑难原因
    ,count(distinct di.pno) 疑难件量
    ,scan.scan_num 交接总量
    ,count(distinct di.pno)/scan.scan_num 疑难件率
    ,scan.cod_num COD交接量
    ,count(distinct if(pi.cod_enabled = 1, di.pno, null)) COD疑难件量
    ,count(distinct if(pi.cod_enabled = 1, di.pno, null))/scan.cod_num COD疑难件率
from t
left join ph_staging.parcel_info pi on pi.pno = t.pno
left join
    (
        select
            di.pno
            ,di.diff_marker_category
        from ph_staging.diff_info di
        join t on di.pno = t.pno
        group by 1,2

        union all

        select
            ppd.pno
            ,ppd.diff_marker_category
        from ph_staging.parcel_problem_detail ppd
        join t on t.pno = ppd.pno
        where
            ppd.parcel_problem_type_category = 2
        group by 1,2
    ) di on di.pno = t.pno
left  join
    (
        select
            t.client_type
            ,count(t.pno) scan_num
            ,count(if(pi.cod_enabled = 1, pi.pno, null)) cod_num
        from t
        left join ph_staging.parcel_info pi on pi.pno = t.pno
        group by 1
    ) scan on scan.client_type = t.client_type
group by 1,2,4,6;
;-- -. . -..- - / . -. - .-. -.--
select
    am.merge_column
    ,am.extra_info
from ph_bi.abnormal_message am
join ph_staging.sys_store ss on ss.id = am.store_id and ss.category = 14 -- PDC
where
    am.abnormal_object = 1 -- 集体处罚
    and am.punish_category = 7 -- 包裹丢失
    and am.abnormal_time >= '2023-01-01'
    and am.abnormal_time < '2023-03-01'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    am.merge_column
    ,am.extra_info
from ph_bi.abnormal_message am
join ph_staging.sys_store ss on ss.id = am.store_id and ss.category = 14 -- PDC
where
    am.abnormal_object = 1 -- 集体处罚
    and am.punish_category = 7 -- 包裹丢失
    and am.abnormal_time >= '2023-01-01'
    and am.abnormal_time < '2023-03-01'
    and am.state = 1
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        am.merge_column
        ,am.extra_info
        ,ss.name
        ,pi.returned
        ,pi.customary_pno
        ,pi.client_id
        ,am.isappeal
    from ph_bi.abnormal_message am
    join ph_staging.sys_store ss on ss.id = am.store_id and ss.category = 14 -- PDC
    left join ph_staging.parcel_info pi on pi.pno = am.merge_column
    where
        am.abnormal_object = 1 -- 集体处罚
        and am.punish_category = 7 -- 包裹丢失
        and am.abnormal_time >= '2023-01-01'
        and am.abnormal_time < '2023-03-01'
        and am.state = 1
    group by 1,2
)
, lost as
(
    select
        pr.pno
        ,pr.staff_info_id
        ,pr.routed_at
    from ph_staging.parcel_route pr
    join  t on pr.pno = t.merge_column
    where
        pr.route_action = 'DIFFICULTY_HANDOVER'
        and json_extract(pr.extra_value, '$.markerCategory') = 22 -- 丢失
)
select
    t.merge_column 单号
    ,t.customary_pno 正向单号
    ,t.name 网点名称
    ,if(t.returned = 0 ,'Fwd', 'Rts') 正向或逆向
    ,case plt.last_valid_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then 'to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 最后一条有效路由
    ,plt.last_valid_routed_at
    ,convert_tz(pri.routed_at, '+00:00', '+08:00') 最后一次打印面单日期
    ,convert_tz(pri2.routed_at, '+00:00', '+08:00') 如果是退件面单，最后一次正向打印面单的日期
    ,if(t.returned = 1, convert_tz(pri.routed_at, '+00:00', '+08:00'), null) 退件面单最后一次打印日期
    ,t.client_id
    ,if(t.isappeal in (2,3,4,5) ,'yes', 'no') 是否有申诉记录
    ,if(c.pno is null , 'NO', 'YES') 'Source C'
    ,case aft.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then ' to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 'Route after Lost was reported'
    ,lost.staff_info_id 'ID that submitted Lost'
    ,convert_tz(aft.routed_at, '+00:00', '+08:00') 'Route after Lost was reported - Time'
    ,convert_tz(lost.routed_at, '+00:00', '+08:00') 'Time lost was reported'
    ,case bef.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then 'to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 'Route before reporting Lost'
    ,group_concat(plr.staff_id)
from t
left join ph_bi.parcel_lose_task plt on plt.id = json_extract(t.extra_info, '$.losr_task_id')
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
        from ph_staging.parcel_route pr
        join t on pr.pno = t.merge_column
        where
            pr.route_action = 'PRINTING'
    ) pri on pri.pno = t.merge_column and pri.rn = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
        from ph_staging.parcel_route pr
        join t on pr.pno = t.customary_pno
        where
            pr.route_action = 'PRINTING'
            and t.returned = 1
    ) pri2 on pri2.pno = t.customary_pno and pri2.rn = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t on t.merge_column = plt.pno
        where
            plt.source = 3
        group by 1
    ) c on c.pno = t.merge_column
left join lost on lost.pno = t.merge_column
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
        from ph_staging.parcel_route pr
        join  t on pr.pno = t.merge_column
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at > lost.routed_at
    ) aft on aft.pno = t.merge_column and aft.rn = 1
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join  t on pr.pno = t.merge_column
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at < lost.routed_at
    ) bef on bef.pno = t.merge_column and bef.rn = 1
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        am.merge_column
        ,am.extra_info
        ,ss.name
        ,pi.returned
        ,pi.customary_pno
        ,pi.client_id
        ,am.isappeal
    from ph_bi.abnormal_message am
    join ph_staging.sys_store ss on ss.id = am.store_id and ss.category = 14 -- PDC
    left join ph_staging.parcel_info pi on pi.pno = am.merge_column
    where
        am.abnormal_object = 1 -- 集体处罚
        and am.punish_category = 7 -- 包裹丢失
        and am.abnormal_time >= '2023-01-01'
        and am.abnormal_time < '2023-03-01'
        and am.state = 1
    group by 1,2
)
, lost as
(
    select
        pr.pno
        ,pr.staff_info_id
        ,pr.routed_at
    from ph_staging.parcel_route pr
    join  t on pr.pno = t.merge_column
    where
        pr.route_action = 'DIFFICULTY_HANDOVER'
        and json_extract(pr.extra_value, '$.markerCategory') = 22 -- 丢失
)
select
    t.merge_column 单号
    ,t.customary_pno 正向单号
    ,t.name 网点名称
    ,if(t.returned = 0 ,'Fwd', 'Rts') 正向或逆向
    ,case plt.last_valid_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then 'to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 最后一条有效路由
    ,plt.last_valid_routed_at
    ,convert_tz(pri.routed_at, '+00:00', '+08:00') 最后一次打印面单日期
    ,convert_tz(pri2.routed_at, '+00:00', '+08:00') '如果是退件面单，最后一次正向打印面单的日期'
    ,if(t.returned = 1, convert_tz(pri.routed_at, '+00:00', '+08:00'), null) 退件面单最后一次打印日期
    ,t.client_id
    ,if(t.isappeal in (2,3,4,5) ,'yes', 'no') 是否有申诉记录
    ,if(c.pno is null , 'NO', 'YES') 'Source C'
    ,case aft.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then ' to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 'Route after Lost was reported'
    ,lost.staff_info_id 'ID that submitted Lost'
    ,convert_tz(aft.routed_at, '+00:00', '+08:00') 'Route after Lost was reported - Time'
    ,convert_tz(lost.routed_at, '+00:00', '+08:00') 'Time lost was reported'
    ,case bef.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then 'to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 'Route before reporting Lost'
    ,group_concat(plr.staff_id)
from t
left join ph_bi.parcel_lose_task plt on plt.id = json_extract(t.extra_info, '$.losr_task_id')
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
        from ph_staging.parcel_route pr
        join t on pr.pno = t.merge_column
        where
            pr.route_action = 'PRINTING'
    ) pri on pri.pno = t.merge_column and pri.rn = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
        from ph_staging.parcel_route pr
        join t on pr.pno = t.customary_pno
        where
            pr.route_action = 'PRINTING'
            and t.returned = 1
    ) pri2 on pri2.pno = t.customary_pno and pri2.rn = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t on t.merge_column = plt.pno
        where
            plt.source = 3
        group by 1
    ) c on c.pno = t.merge_column
left join lost on lost.pno = t.merge_column
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
        from ph_staging.parcel_route pr
        join  t on pr.pno = t.merge_column
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at > lost.routed_at
    ) aft on aft.pno = t.merge_column and aft.rn = 1
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join  t on pr.pno = t.merge_column
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at < lost.routed_at
    ) bef on bef.pno = t.merge_column and bef.rn = 1
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
        am.merge_column
        ,am.extra_info
        ,ss.name
        ,pi.returned
        ,pi.customary_pno
        ,pi.client_id
        ,am.isappeal
    from ph_bi.abnormal_message am
    join ph_staging.sys_store ss on ss.id = am.store_id and ss.category = 14 -- PDC
    left join ph_staging.parcel_info pi on pi.pno = am.merge_column
    where
        am.abnormal_object = 1 -- 集体处罚
        and am.punish_category = 7 -- 包裹丢失
        and am.abnormal_time >= '2023-01-01'
        and am.abnormal_time < '2023-03-01'
        and am.state = 1
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        am.merge_column
        ,json_extract(am.extra_info, '$.losr_task_id') lose_task_id
        ,ss.name
        ,pi.returned
        ,pi.customary_pno
        ,pi.client_id
        ,am.isappeal
    from ph_bi.abnormal_message am
    join ph_staging.sys_store ss on ss.id = am.store_id and ss.category = 14 -- PDC
    left join ph_staging.parcel_info pi on pi.pno = am.merge_column
    where
        am.abnormal_object = 1 -- 集体处罚
        and am.punish_category = 7 -- 包裹丢失
        and am.abnormal_time >= '2023-01-01'
        and am.abnormal_time < '2023-03-01'
        and am.state = 1
    group by 1,2
)
, lost as
(
    select
        pr.pno
        ,pr.staff_info_id
        ,pr.routed_at
    from ph_staging.parcel_route pr
    join  t on pr.pno = t.merge_column
    where
        pr.route_action = 'DIFFICULTY_HANDOVER'
        and json_extract(pr.extra_value, '$.markerCategory') = 22 -- 丢失
)
select
    t.merge_column 单号
    ,t.customary_pno 正向单号
    ,t.name 网点名称
    ,if(t.returned = 0 ,'Fwd', 'Rts') 正向或逆向
    ,case plt.last_valid_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then 'to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 最后一条有效路由
    ,plt.last_valid_routed_at 最后一条有效路由时间
    ,convert_tz(pri.routed_at, '+00:00', '+08:00') 最后一次打印面单日期
    ,convert_tz(pri2.routed_at, '+00:00', '+08:00') '如果是退件面单，最后一次正向打印面单的日期'
    ,if(t.returned = 1, convert_tz(pri.routed_at, '+00:00', '+08:00'), null) 退件面单最后一次打印日期
    ,t.client_id
    ,if(t.isappeal in (2,3,4,5) ,'yes', 'no') 是否有申诉记录
    ,if(c.pno is null , 'NO', 'YES') 'Source C'
    ,case aft.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then ' to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 'Route after Lost was reported'
    ,lost.staff_info_id 'ID that submitted Lost'
    ,convert_tz(aft.routed_at, '+00:00', '+08:00') 'Route after Lost was reported - Time'
    ,convert_tz(lost.routed_at, '+00:00', '+08:00') 'Time lost was reported'
    ,case bef.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then 'to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 'Route before reporting Lost'
    ,group_concat(plr.staff_id) staff
from t
left join ph_bi.parcel_lose_task plt on plt.id = t.lose_task_id
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
        from ph_staging.parcel_route pr
        join t on pr.pno = t.merge_column
        where
            pr.route_action = 'PRINTING'
    ) pri on pri.pno = t.merge_column and pri.rn = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
        from ph_staging.parcel_route pr
        join t on pr.pno = t.customary_pno
        where
            pr.route_action = 'PRINTING'
            and t.returned = 1
    ) pri2 on pri2.pno = t.customary_pno and pri2.rn = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t on t.merge_column = plt.pno
        where
            plt.source = 3
        group by 1
    ) c on c.pno = t.merge_column
left join lost on lost.pno = t.merge_column
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
        from ph_staging.parcel_route pr
        join  t on pr.pno = t.merge_column
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at > lost.routed_at
    ) aft on aft.pno = t.merge_column and aft.rn = 1
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join  t on pr.pno = t.merge_column
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at < lost.routed_at
    ) bef on bef.pno = t.merge_column and bef.rn = 1
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = plt.id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
        am.merge_column
        ,json_extract(am.extra_info, '$.losr_task_id') lose_task_id
        ,ss.name
        ,pi.returned
        ,pi.customary_pno
        ,pi.client_id
        ,am.isappeal
    from ph_bi.abnormal_message am
    join ph_staging.sys_store ss on ss.id = am.store_id and ss.category = 14 -- PDC
    left join ph_staging.parcel_info pi on pi.pno = am.merge_column
    where
        am.abnormal_object = 1 -- 集体处罚
        and am.punish_category = 7 -- 包裹丢失
        and am.abnormal_time >= '2023-01-01'
        and am.abnormal_time < '2023-03-01'
        and am.state = 1
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        am.merge_column
        ,json_extract(am.extra_info, '$.losr_task_id') lose_task_id
        ,ss.name
        ,pi.returned
        ,pi.customary_pno
        ,pi.client_id
        ,am.isappeal
    from ph_bi.abnormal_message am
    join ph_staging.sys_store ss on ss.id = am.store_id and ss.category = 14 -- PDC
    left join ph_staging.parcel_info pi on pi.pno = am.merge_column
    where
        am.abnormal_object = 1 -- 集体处罚
        and am.punish_category = 7 -- 包裹丢失
        and am.abnormal_time >= '2023-01-01'
        and am.abnormal_time < '2023-03-01'
        and am.state = 1
    group by 1,2
)
, lost as
(
    select
        pr.pno
        ,pr.staff_info_id
        ,pr.routed_at
    from ph_staging.parcel_route pr
    join  t on pr.pno = t.merge_column
    where
        pr.route_action = 'DIFFICULTY_HANDOVER'
        and json_extract(pr.extra_value, '$.markerCategory') = 22 -- 丢失
)
select
    t.merge_column 单号
    ,t.customary_pno 正向单号
    ,t.name 网点名称
    ,if(t.returned = 0 ,'Fwd', 'Rts') 正向或逆向
    ,case pr.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then 'to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 最后一条有效路由
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一条有效路由时间
    ,convert_tz(pri.routed_at, '+00:00', '+08:00') 最后一次打印面单日期
    ,convert_tz(pri2.routed_at, '+00:00', '+08:00') '如果是退件面单，最后一次正向打印面单的日期'
    ,if(t.returned = 1, convert_tz(pri.routed_at, '+00:00', '+08:00'), null) 退件面单最后一次打印日期
    ,t.client_id
    ,if(t.isappeal in (2,3,4,5) ,'yes', 'no') 是否有申诉记录
    ,if(c.pno is null , 'NO', 'YES') 'Source C'
    ,case aft.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then ' to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 'Route after Lost was reported'
    ,lost.staff_info_id 'ID that submitted Lost'
    ,convert_tz(aft.routed_at, '+00:00', '+08:00') 'Route after Lost was reported - Time'
    ,convert_tz(lost.routed_at, '+00:00', '+08:00') 'Time lost was reported'
    ,case bef.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then 'to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 'Route before reporting Lost'
    ,group_concat(plr.staff_id) staff
from t
left join
    (
          select
            pr.pno
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join  t on t.merge_column = pr.pno
        where  -- 最后有效路由
            pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN','DELIVERY_PICKUP_STORE_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','REFUND_CONFIRM','ACCEPT_PARCEL')
    ) pr on pr.pno = t.merge_column and pr.rn = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
        from ph_staging.parcel_route pr
        join t on pr.pno = t.merge_column
        where
            pr.route_action = 'PRINTING'
    ) pri on pri.pno = t.merge_column and pri.rn = 1
left join
    (
        select
            pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rn
        from ph_staging.parcel_route pr
        join t on pr.pno = t.customary_pno
        where
            pr.route_action = 'PRINTING'
            and t.returned = 1
    ) pri2 on pri2.pno = t.customary_pno and pri2.rn = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t on t.merge_column = plt.pno
        where
            plt.source = 3
        group by 1
    ) c on c.pno = t.merge_column
left join lost on lost.pno = t.merge_column
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at ) rn
        from ph_staging.parcel_route pr
        join  t on pr.pno = t.merge_column
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at > lost.routed_at
    ) aft on aft.pno = t.merge_column and aft.rn = 1
left join
    (
        select
            pr.pno
            ,pr.staff_info_id
            ,pr.route_action
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
        from ph_staging.parcel_route pr
        join  t on pr.pno = t.merge_column
        left join lost on pr.pno = lost.pno
        where
            pr.routed_at < lost.routed_at
    ) bef on bef.pno = t.merge_column and bef.rn = 1
left join ph_bi.parcel_lose_responsible plr on plr.lose_task_id = t.lose_task_id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        am.merge_column
        ,json_extract(am.extra_info, '$.losr_task_id') lose_task_id
        ,ss.name
        ,pi.returned
        ,pi.customary_pno
        ,pi.client_id
        ,am.isappeal
    from ph_bi.abnormal_message am
    join ph_staging.sys_store ss on ss.id = am.store_id and ss.category = 14 -- PDC
    left join ph_staging.parcel_info pi on pi.pno = am.merge_column
    where
        am.abnormal_object = 1 -- 集体处罚
        and am.punish_category = 7 -- 包裹丢失
        and am.abnormal_time >= '2023-01-01'
        and am.abnormal_time < '2023-03-01'
        and am.state = 1
    group by 1,2
)
select
    t.merge_column
    ,case pr.route_action
        when 'RECEIVED' then 'Pickup by Courier'
        when 'RECEIVE_WAREHOUSE_SCAN' then 'Courier to DC'
        when 'DELIVERY_TICKET_CREATION_SCAN' then 'Handover Scan'
        when 'ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan'
        when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then 'Inbound Attendance'
        when 'DEPARTURE_GOODS_VAN_CK_SCAN' then 'Outbound Attendance'
        when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then 'Cancel Arrival scan in'
        when 'HAVE_HAIR_SCAN_NO_TO' then 'report Shipped Parcels without Arrival'
        when 'SHIPMENT_WAREHOUSE_SCAN' then 'Loading scan'
        when 'CANCEL_SHIPMENT_WAREHOUSE' then 'cancel departure scan'
        when 'DETAIN_WAREHOUSE' then 'Detained at current station'
        when 'DELIVERY_CONFIRM' then 'Finished Delivery'
        when 'DIFFICULTY_HANDOVER' then 'Problem shipment handover'
        when 'CONTINUE_TRANSPORT' then 'Continue delivery'
        when 'DIFFICULTY_INDEMNITY' then 'Problem shipment compensation'
        when 'DIFFICULTY_RETURN' then 'Problem shipment return to sender'
        when 'DIFFICULTY_RE_TRANSIT' then 'Problem shipment return to DC/re-delivery'
        when 'CLOSE_ORDER' then 'Delivery terminated'
        when 'DIFFICULTY_DETAIN' then 'Problem shipment retained in station'
        when 'DIFFICULTY_FINISH_INDEMNITY' then 'Problem shipment has been paid'
        when 'DIFFICULTY_FINISH_RETURN' then 'Problem shipment return print'
        when 'CANCEL_PARCEL' then 'shipment cancelled'
        when 'DELIVERY_MARKER' then 'Delivery Mark'
        when 'REPLACE_PNO' then 'Replace Waybill'
        when 'SEAL' then 'Bagging Scan'
        when 'UNSEAL' then 'Unbagging Scan'
        when 'UNSEAL_NO_PARCEL' then 'Report the parcel is not in the bagging'
        when 'DIFFICULTY_SEAL' then 'Bagging exception'
        when 'SEAL_NUMBER_CHANGE' then 'Parcels in a bagging is scanned separately'
        when 'UNSEAL_NOT_SCANNED' then 'The bag has been unbagging. This parcel was not been scanned'
        when 'PARCEL_HEADLESS_CLAIMED' then 'No label parcel has been retrieved'
        when 'PARCEL_HEADLESS_PRINTED' then 'No label parcel has been printed label'
        when 'PHONE' then 'Phone contact'
        when 'HURRY_PARCEL' then 'Reminder'
        when 'MANUAL_REMARK' then 'Shipment remark'
        when 'INTERRUPT_PARCEL_AND_RETURN' then 'Interrupt and return'
        when 'CHANGE_PARCEL_INFO' then 'Modify shipment’s info'
        when 'CUSTOMER_CHANGE_PARCEL_INFO' then 'Customer Modify Package Information'
        when 'CHANGE_PARCEL_CLOSE' then 'Close the waybill'
        when 'CHANGE_PARCEL_SIGNED' then 'Confirm that the customer has received this shipment'
        when 'CHANGE_PARCEL_CANCEL' then 'shipment cancelled'
        when 'STAFF_INFO_UPDATE_WEIGHT' then 'Courier changes weight'
        when 'STORE_KEEPER_UPDATE_WEIGHT' then 'Warehouse keeper re-weight'
        when 'STORE_SORTER_UPDATE_WEIGHT' then 'Reweighed by sorter machine'
        when 'THIRD_EXPRESS_ROUTE' then 'Third-party courier company routing'
        when 'EXCHANGE_PARCEL' then 'Exchange goods&Return'
        when 'DISCARD_RETURN_BKK' then 'Re-print the waybill and send to auction warehouse'
        when 'DELIVERY_TRANSFER' then 'Task reassign'
        when 'PICKUP_RETURN_RECEIPT' then 'pickup return receipt'
        when 'CHANGE_PARCEL_IN_TRANSIT' then 'Modify the package to be in transit'
        when 'FLASH_HOME_SCAN' then 'to courier'
        when 'INCOMING_CALL' then 'Answered the consignee call'
        when 'REVISION_TIME' then 'Change time'
        when 'TRANSFER_LOST_PARTS_TEAM' then 'Handover to SS Judge System (Lost)'
        when 'NOTICE_LOST_PARTS_TEAM' then 'Synchronize to SS Judge System (Non-Lost)'
        when 'LOSE_PARCEL_TEAM_OPERATION' then 'SS Judge System Process'
        when 'THIRD_PARTY_REASON_DETAIN' then 'Third party detention'
        when 'CREATE_WORK_ORDER' then 'Create the ticket'
        when 'REPLY_WORK_ORDER' then 'Reply the ticket'
        when 'PRINTING' then 'Print Label'
        when 'seal.ARRIVAL_WAREHOUSE_SCAN' then 'Unloading Scan for Bagging'
        when 'CUSTOMER_OPERATING_RETURN' then 'Customer operation returns to sender'
        when 'SYSTEM_AUTO_RETURN' then 'system auto return'
        when 'INVENTORY' then 'Inventory check'
        when 'REPAIRED' then 'Package repair'
        when 'DELIVERY_PICKUP_STORE_SCAN' then 'Scan code to sign for package by BS'
        when 'FORCE_TAKE_PHOTO' then 'Compulsory photo'
        when 'TAKE_PHOTO' then 'Abnormal ordering and taking photos'
        when 'DISTRIBUTION_INVENTORY' then 'Hub Inventory Check'
    end 最后一条有效路由
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 最后一条有效路由时间
from t
left join
(
      select
        pr.pno
        ,pr.route_action
        ,pr.routed_at
        ,row_number() over (partition by pr.pno order by pr.routed_at desc) rn
    from ph_staging.parcel_route pr
    join  t on t.merge_column = pr.pno
    where  -- 最后有效路由
        pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN','ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM','DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED','STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT','DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN','seal.ARRIVAL_WAREHOUSE_SCAN','INVENTORY','SORTING_SCAN','DELIVERY_PICKUP_STORE_SCAN','DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE','REFUND_CONFIRM','ACCEPT_PARCEL')
) pr on pr.pno = t.merge_column and pr.rn = 1;
;-- -. . -..- - / . -. - .-. -.--
select DATE_FORMAT(curdate() ,'%Y%m');
;-- -. . -..- - / . -. - .-. -.--
SELECT
	DATE_FORMAT(plt.`updated_at`, '%Y%m%d') '统计日期 Statistical date'
	,if(plt.`duty_result`=3,pr.store_name,ss.`name`) '网点名称 store name'
	,smp.`name` '片区Area'
	,smr.`name` '大区District'
	,pi.`揽件包裹Qty. of pick up parcel`
	,pi2.`妥投包裹Qty. of delivered parcel`
	,COUNT(DISTINCT(if(plt.`duty_result`=1 and plt.`duty_type` in(4),plt.`pno`,null)))*0.5+COUNT(DISTINCT(if(plt.`duty_result`=1 and plt.`duty_type` not in(4),plt.`pno`,null))) '丢失 Lost'
	,COUNT(DISTINCT(if(plt.`duty_result`=2 and plt.`duty_type` in(4),plt.`pno`,null)))*0.5+COUNT(DISTINCT(if(plt.`duty_result`=2 and plt.`duty_type` not in(4),plt.`pno`,null))) '破损 Dmaged'
	,COUNT(DISTINCT(if(plt.`duty_result`=3 and plt.`duty_type` in(4),plt.`pno`,null)))*0.5+COUNT(DISTINCT(if(plt.`duty_result`=3 and plt.`duty_type` not in(4),plt.`pno`,null))) '超时包裹 Over SLA'
	,sum(if(plt.`duty_result`=1,pcn.claim_money,0)) '丢失理赔金额 Lost claim amount'
	,sum(if(plt.`duty_result`=2,pcn.claim_money,0)) '破损理赔金额 Damage claim amount'
	,sum(if(plt.`duty_result`=3,pcn.claim_money,0)) '超时效理赔金额 Over SLA claim amount'
FROM  `ph_bi`.`parcel_lose_task` plt
LEFT JOIN `ph_bi`.`parcel_lose_responsible` plr on plr.`lose_task_id` =plt.`id`
LEFT JOIN `ph_bi`.`sys_store` ss on ss.`id` = plr.`store_id`
LEFT JOIN `ph_bi`.`sys_manage_region` smr on smr.`id`  =ss.`manage_region`
LEFT JOIN `ph_bi`.`sys_manage_piece` smp on smp.`id`  =ss.`manage_piece`
LEFT JOIN ( SELECT
                    DATE_FORMAT(convert_tz(pi.`created_at`,'+00:00','+08:00'),'%Y%m%d') 揽收日期
                    ,pi.`ticket_pickup_store_id`
           			,COUNT( DISTINCT(pi.pno)) '揽件包裹Qty. of pick up parcel'
             FROM `ph_staging`.`parcel_info` pi
           	 where pi.`state`<9
           	 and DATE_FORMAT(convert_tz(pi.`created_at`,'+00:00','+08:00'),'%Y-%m-%d') >= date_sub(curdate(), interval 31 day)
             GROUP BY 1,2
            ) pi on pi.揽收日期=DATE_FORMAT(plt.`updated_at`, '%Y%m%d') and pi.`ticket_pickup_store_id`= plr.`store_id`
LEFT JOIN ( SELECT
                    DATE_FORMAT(convert_tz(pi.`finished_at`, '+00:00','+08:00'),'%Y%m%d') 妥投日期
                    ,pi.`ticket_delivery_store_id`
           			,COUNT( DISTINCT(if(pi.state=5,pi.pno,null))) '妥投包裹Qty. of delivered parcel'
             FROM `ph_staging`.`parcel_info` pi
           	 where pi.`state`<9
           	 and DATE_FORMAT(convert_tz(pi.`finished_at`, '+00:00','+08:00'),'%Y-%m-%d') >= date_sub(curdate(), interval 31 day)
             GROUP BY 1,2
            ) pi2 on pi2.妥投日期=DATE_FORMAT(plt.`updated_at`, '%Y%m%d') and pi2.`ticket_delivery_store_id`= plr.`store_id`
LEFT JOIN
(

    SELECT *
     FROM
           (
                 SELECT pct.`pno`
                               ,pct.`id`
                    ,pct.`finance_updated_at`
                             ,pct.`state`
                               ,pct.`created_at`
                        ,row_number() over (partition by pct.`pno` order by pct.`created_at` DESC ) row_num
             FROM `ph_bi`.parcel_claim_task pct
             where pct.state=6
           )t0
    WHERE t0.row_num=1
)pct on pct.pno=plt.pno
LEFT  join
        (
            select *
            from
                (
                select
                pcn.`task_id`
                ,replace(json_extract(pcn.`neg_result`,'$.money'),'\"','') claim_money
                ,row_number() over (partition by pcn.`task_id` order by pcn.`created_at` DESC ) row_num
                from `ph_bi`.parcel_claim_negotiation pcn
                ) t1
            where t1.row_num=1
        )pcn on pcn.task_id =pct.`id`
LEFT JOIN (select pr.`pno`,pr.store_id,pr.`routed_at`,pr.route_action,pr.store_name,pr.staff_info_id,pr.staff_info_phone,pr.staff_info_name,pr.extra_value
           from (select
         pr.`pno`,pr.store_id,pr.`routed_at`,pr.route_action,pr.store_name,pr.staff_info_id,pr.staff_info_phone,pr.staff_info_name,pr.extra_value,
         row_number() over(partition by pr.`pno` order by pr.`routed_at` desc) as rn
         from `ph_staging`.`parcel_route` pr
         where pr.`routed_at`>= CONVERT_TZ('2022-12-01','+08:00','+00:00')
         and pr.`route_action` in(
             select dd.`element`  from dwm.dwd_dim_dict dd where dd.remark ='valid')
                ) pr
         where pr.rn = 1
        ) pr on pr.pno=plt.`pno`
where plt.`state` in (6)
and plt.`operator_id` not in ('10000','10001')
and DATE_FORMAT(plt.`updated_at`, '%Y-%m-%d') >= date_sub(curdate(), interval 31 day)
and plt.`updated_at` IS NOT NULL
GROUP BY 1,2,3,4
ORDER BY 1,2;
;-- -. . -..- - / . -. - .-. -.--
SELECT DISTINCT

	plt.created_at '任务生成时间 Task generation time'
    ,CONCAT('SSRD',plt.`id`) '任务ID Task ID'
	,plt.`pno`  '运单号 Waybill'
	,case plt.`vip_enable`
    when 0 then '普通客户'
    when 1 then 'KAM客户'
    end as '客户类型 Client type'
	,case plt.`duty_result`
	when 1 then '丢失'
	when 2 then '破损'
	when 3 then '超时效'
	end as '判责类型Judgement type'
	,t.`t_value` '原因 Reason'
	,plt.`client_id` '客户ID Client ID'
	,pi.`cod_amount`/100 'COD金额 COD'
	,plt.`parcel_created_at` '揽收时间 Pick up time'
	,cast(pi.exhibition_weight as double)/1000 '重量 Weight'
    ,concat(pi.exhibition_length,'*',pi.exhibition_width,'*',pi.exhibition_height) '尺寸 Size'
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
    end  as '包裹品类 Item type'
	,pr.route_action 最后一条有效路由动作
	,wo.`order_no` '工单号 Ticket No.'
	,case  plt.`source`
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
		WHEN 11 THEN 'K-超时效'
		when 12 then 'L-高度疑似丢失'
		END AS '问题件来源渠道 Source channel of issue'
	,case plt.`state`
	when 5 then '无需追责'
	when 6 then '责任人已认定'
	end  as '状态 Status'
    ,plt.`fleet_stores` '异常区间 Abnormal interval'
    ,ft.`line_name`  '异常车线  Abnormal LH'
	,plt.`operator_id` '处理人 Handler'
	,plt.`updated_at` '处理时间 Handle time'
	,plt.`penalty_base` '判罚依据 Basis of penalty'
    ,case plt.`link_type`
    WHEN 0 THEN 'ipc计数后丢失'
    WHEN 1 THEN '揽收网点已揽件，未收件入仓'
    WHEN 2 THEN '揽收网点已收件入仓，未发件出仓'
    WHEN 3 THEN '中转已到件入仓扫描，中转未发件出仓'
    WHEN 4 THEN '揽收网点已发件出仓扫描，分拨未到件入仓(集包)'
    WHEN 5 THEN '揽收网点已发件出仓扫描，分拨未到件入仓(单件)'
    WHEN 6 THEN '分拨发件出仓扫描，目的地未到件入仓(集包)'
    WHEN 7 THEN '分拨发件出仓扫描，目的地未到件入仓(单件)'
    WHEN 8 THEN '目的地到件入仓扫描，目的地未交接,当日遗失'
    WHEN 9 THEN '目的地到件入仓扫描，目的地未交接,次日遗失'
    WHEN 10 THEN '目的地交接扫描，目的地未妥投'
    WHEN 11 THEN '目的地妥投后丢失'
    WHEN 12 THEN '途中破损/短少'
    WHEN 13 THEN '妥投后破损/短少'
    WHEN 14 THEN '揽收网点已揽件，未收件入仓'
    WHEN 15 THEN '揽收网点已收件入仓，未发件出仓'
    WHEN 16 THEN '揽收网点发件出仓到分拨了'
    WHEN 17 THEN '目的地到件入仓扫描，目的地未交接'
    WHEN 18 THEN '目的地交接扫描，目的地未妥投'
    WHEN 19 THEN '目的地妥投后破损短少'
    WHEN 20 THEN '分拨已发件出仓，下一站分拨未到件入仓(集包)'
    WHEN 21 THEN '分拨已发件出仓，下一站分拨未到件入仓(单件)'
    WHEN 22 THEN 'ipc计数后丢失'
    WHEN 23 THEN '超时效SLA'
    WHEN 24 THEN '分拨发件出仓到下一站分拨了'
	end as '判责环节 Judgement'
    ,case if(plt.state= 6,plt.`duty_type`,null)
	when 1 then '快递员100%套餐'
    when 2 then '仓7主3套餐(仓管70%主管30%)'
 	when 4 then '双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
    when 5 then  '快递员721套餐(快递员70%仓管20%主管10%)'
    when 6 then  '仓管721套餐(仓管70%快递员20%主管10%)'
    when 8 then  'LH全责（LH100%）'
    when 7 then  '其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
    when 21 then  '仓7主3套餐(仓管70%主管30%)'
	end as '套餐 Penalty plan'
	,ss3.`name` '责任网点 Resposible DC'
	,case pct.state
                when 1 then '丢失件待协商'
                when 2 then '协商不一致'
                when 3 then '待财务核实'
                when 4 then '待财务支付'
                when 5 then '支付驳回'
                when 6 then '理赔完成'
                when 7 then '理赔终止'
                when 8 then '异常关闭'
                end as '理赔处理状态 Status of claim'
	,if(pct.state=6,pcn.claim_money,0) '理赔金额 Claim amount'
	,timestampdiff( hour ,plt.`created_at` ,plt.`updated_at`) '处理时效 Processing SLA'
	,DATE_FORMAT(plt.`updated_at`,'%Y%m%d') '统计日期 Statistical date'
	,plt.`remark` 备注




FROM  `ph_bi`.`parcel_lose_task` plt
LEFT JOIN `ph_staging`.`parcel_info`  pi on pi.pno = plt.pno
LEFT JOIN `ph_bi`.`sys_store` ss on ss.id = pi.`ticket_pickup_store_id`
LEFT JOIN `ph_bi`.`sys_store` ss1 on ss1.id = pi.`dst_store_id`

LEFT JOIN `ph_bi`.`work_order` wo on wo.`loseparcel_task_id` = plt.`id`
LEFT JOIN `ph_bi`.`fleet_time` ft on ft.`proof_id` =LEFT (plt.`fleet_routeids`,11)
LEFT JOIN `ph_bi`.`parcel_lose_stat_detail` pld on pld. `lose_task_id`=plt.`id`
LEFT JOIN `ph_bi`.`parcel_lose_responsible` plr on plr.`lose_task_id`=plt.`id`
LEFT JOIN `ph_bi`.`sys_store` ss3 on ss3.id = plr.store_id
LEFT JOIN `ph_bi`.`translations` t ON plt.duty_reasons = t.t_key AND t.`lang` = 'zh-CN'
LEFT JOIN
(

    SELECT *
     FROM
           (
                 SELECT pct.`pno`
                               ,pct.`id`
                    ,pct.`finance_updated_at`
                             ,pct.`state`
                               ,pct.`created_at`
                        ,row_number() over (partition by pct.`pno` order by pct.`created_at` DESC ) row_num
             FROM `ph_bi`.parcel_claim_task pct

           )t0
    WHERE t0.row_num=1
)pct on pct.pno=plt.pno
LEFT  join
        (
            select *
            from
                (
                select
                pcn.`task_id`
                ,replace(json_extract(pcn.`neg_result`,'$.money'),'\"','') claim_money
                ,row_number() over (partition by pcn.`task_id` order by pcn.`created_at` DESC ) row_num
                from `ph_bi`.parcel_claim_negotiation pcn
                ) t1
            where t1.row_num=1
        )pcn on pcn.task_id =pct.`id`
LEFT JOIN (select pr.`pno`,pr.store_id,pr.`routed_at`,pr.route_action,pr.store_name,pr.staff_info_id,pr.staff_info_phone,pr.staff_info_name,pr.extra_value
           from (select
         pr.`pno`,pr.store_id,pr.`routed_at`,pr.route_action,pr.store_name,pr.staff_info_id,pr.staff_info_phone,pr.staff_info_name,pr.extra_value,
         row_number() over(partition by pr.`pno` order by pr.`routed_at` desc) as rn
         from `ph_staging`.`parcel_route` pr
         where pr.`routed_at`>= CONVERT_TZ('2022-12-01','+08:00','+00:00')
         and pr.`route_action` in(
             select dd.`element`  from dwm.dwd_dim_dict dd where dd.remark ='valid')
                ) pr
         where pr.rn = 1
        ) pr on pr.pno=plt.`pno`
where 1=1
and plt.`state` in (5,6)
and plt.`operator_id` not in ('10000','10001')
and DATE_FORMAT(plt.`updated_at`, '%Y-%m-%d') >= date_sub(curdate(), interval 31 day)
GROUP BY 2
ORDER BY 2;
;-- -. . -..- - / . -. - .-. -.--
select DATE_FORMAT(curdate() ,'%Y-%m-%d');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.store_total_amount
    ,pi.store_parcel_amount
    ,pi.cod_poundage_amount
    ,pi.material_amount
    ,pi.insure_amount
    ,pi.freight_insure_amount
    ,pi.label_amount
from ph_staging.parcel_info pi
where
    pi.pno = 'P18031DPPG5BQ';
;-- -. . -..- - / . -. - .-. -.--
select
    pi.store_total_amount
    ,pi.store_parcel_amount
    ,pi.cod_poundage_amount
    ,pi.material_amount
    ,pi.insure_amount
    ,pi.freight_insure_amount
    ,pi.label_amount
    ,pi.cod_amount
from ph_staging.parcel_info pi
where
    pi.pno = 'P18031DPPG5BQ';
;-- -. . -..- - / . -. - .-. -.--
select
    pcd.pno
    ,if(pi.returned = 0, '正向', '逆向') 包裹流向
    ,pi.customary_pno 原单号
    ,oi.cogs_amount cog金额
    ,pi2.store_total_amount 总运费
    ,pi2.cod_amount/100 COD金额
    ,pi2.cod_poundage_amount COD手续费
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 当前包裹状态
from ph_staging.parcel_change_detail pcd
left join ph_staging.parcel_info pi on pcd.pno = pi.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)
left join ph_staging.order_info oi on if(pi.returned = 0, pi.pno, pi.customary_pno) = oi.pno
where
    pcd.new_value = 'PH19040F05'
    and pcd.created_at >= '2023-01-31 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    pcd.pno
    ,if(pi.returned = 0, '正向', '逆向') 包裹流向
    ,pi.customary_pno 原单号
    ,oi.cogs_amount/100 cog金额
    ,pi2.store_total_amount 总运费
    ,pi2.cod_amount/100 COD金额
    ,pi2.cod_poundage_amount COD手续费
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 当前包裹状态
from ph_staging.parcel_change_detail pcd
left join ph_staging.parcel_info pi on pcd.pno = pi.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 0, pi.pno, pi.customary_pno)
left join ph_staging.order_info oi on if(pi.returned = 0, pi.pno, pi.customary_pno) = oi.pno
where
    pcd.new_value = 'PH19040F05'
    and pcd.created_at >= '2023-01-31 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    *
from tmpale.tmp_ph_test_0406;
;-- -. . -..- - / . -. - .-. -.--
select
    t.dated
    ,t.staff
    ,count(distinct t.pno) num
    ,group_concat(t.pno) pno
from tmpale.tmp_ph_test_0406 t
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.category
from ph_staging.parcel_headless ph
left join ph_staging.sys_store ss on ss.id = ph.submit_store_id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.category
    ,ss2.category category2
from ph_staging.parcel_headless ph
left join ph_staging.sys_store ss on ss.id = ph.submit_store_id
left join ph_staging.sys_store ss2 on ss2.id = ph.claim_store_id
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.category
    ,ss2.category
    ,count(ph.hno) num
from ph_staging.parcel_headless ph
left join ph_staging.sys_store ss on ss.id = ph.submit_store_id
left join ph_staging.sys_store ss2 on ss2.id = ph.claim_store_id
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.category
    ,ss2.category
    ,count(ph.hno) num
from ph_staging.parcel_headless ph
left join ph_staging.sys_store ss on ss.id = ph.submit_store_id
left join ph_staging.sys_store ss2 on ss2.id = ph.claim_store_id
where
    ph.claim_store_id is not null
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name
    ,ss2.name name2
    ,count(ph.hno) num
from ph_staging.parcel_headless ph
left join ph_staging.sys_store ss on ss.id = ph.submit_store_id
left join ph_staging.sys_store ss2 on ss2.id = ph.claim_store_id
where
    ph.claim_store_id is not null
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select #应集包
            pr.`store_id`
            ,count(distinct pr.`pno`) 应集包量
        from `ph_staging`.`parcel_route` pr
        left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
        left join ph_staging.parcel_route pr2 on pr2.pno = pr.pno and pr2.route_action = 'UNSEAL' and DATE_FORMAT(CONVERT_TZ(pr2.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day) and pr2.store_id = pr.store_id
        where
            pr.`route_action` in ('SHIPMENT_WAREHOUSE_SCAN')
            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
            and pi.`exhibition_weight`<=3000
            and (pi.`exhibition_length` +pi.`exhibition_width` +pi.`exhibition_height`)<=60
            and pi.`exhibition_length` <=30
            and pi.`exhibition_width` <=30
            and pi.`exhibition_height` <=30
            and pr2.pno is not null
        GROUP BY 1;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    date_sub(curdate(),interval 1 day) 日期
    ,ss.`name` 网点名称
    ,smr.`name` 大区
    ,smp.`name` 片区
    ,v2.出勤收派员人数
    ,v2.出勤仓管人数
    ,v2.出勤主管人数
    ,pr.妥投量
    ,pr1.应到量
    ,pr2.实到量
    ,concat(round(pr2.实到量/pr1.应到量,4)*100,'%') 到件入仓率
    ,dc.应派量
    ,pr3.交接量
    ,concat(round(pr3.交接量/dc.应派量,4)*100,'%') 交接率
    ,pr4.应盘点量
    ,pr5.实际盘点量
    ,pr4.应盘点量- pr5.实际盘点量 未盘点量
    ,concat(round(pr5.实际盘点量/pr4.应盘点量,4)*100,'%') 盘点率
    ,pr6.应集包量
    ,pr7.实际集包量
    ,concat(round(pr7.实际集包量/pr6.应集包量,4)*100,'%') 集包率
from
    (
        select
            *
        from `ph_staging`.`sys_store` ss
        where
            ss.category in (8,12)
            and ss.state = 1
    ) ss
left join `ph_staging`.`sys_manage_region` smr on smr.`id`  =ss.`manage_region`
left join `ph_staging`.`sys_manage_piece` smp on smp.`id`  =ss.`manage_piece`
left join
    (
        select #出勤
            hi.`sys_store_id`
            ,count(distinct(if(v2.`job_title` in (13,110,807,1000),v2.`staff_info_id`,null))) 出勤收派员人数
            ,count(distinct(if(v2.`job_title` in (37),v2.`staff_info_id`,null))) 出勤仓管人数
            ,count(distinct(if(v2.`job_title` in (16,272),v2.`staff_info_id`,null))) 出勤主管人数
        from `ph_bi`.`attendance_data_v2` v2
        left join `ph_bi`.`hr_staff_info` hi on hi.`staff_info_id` =v2.`staff_info_id`
        where
            v2.`stat_date`=date_sub(curdate(),interval 1 day)
            and
                (v2.`attendance_started_at` is not null or v2.`attendance_end_at` is not null)
        group by 1
    )v2 on v2.`sys_store_id`=ss.`id`
left join
    (
        select #妥投
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 妥投量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('DELIVERY_CONFIRM')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y%m%d') = date_sub(curdate(),interval 1 day)
        group by 1
    )pr on pr.`store_id`=ss.`id`
LEFT JOIN
    (
        select #应到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应到量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y%m%d') = date_sub(curdate(),interval 1 day)
        group by 1
    )pr1 on pr1.`store_id`=ss.`id`
left join
    (
        select #实到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实到量
        from
            (
                select #车货关联到港
                    pr.`pno`
                    ,pr.`store_id`
                    ,pr.`routed_at`
                from `ph_staging`.`parcel_route` pr
                where
                    pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
                    and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
            )pr
        join
            (
                select #有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`routed_at`
                    ,pr.route_action
                    ,pr.store_name
                    ,pr.staff_info_id
                    ,pr.staff_info_phone
                    ,pr.staff_info_name
                    ,pr.extra_value
                from `ph_staging`.`parcel_route` pr
                where
                    pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                       'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                       'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                       'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                    and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d') >= date_sub(curdate(),interval 1 day)
            ) pr1 on pr1.pno = pr.`pno`
        where
            pr1.store_id=pr.store_id
            and pr1.`routed_at`<= date_add(pr.`routed_at`,interval 4 hour)
        group by 1
    )pr2 on  pr2.`store_id`=ss.`id`
left join
    (
        select #应派
            dc.`store_id`
            ,count(distinct(dc.`pno`)) 应派量
        from `ph_bi`.`dc_should_delivery_today` dc
        where
            dc.`stat_date`= date_sub(curdate(),interval 1 day)
        group by 1
    ) dc on dc.`store_id`=ss.`id`
left join
    (
        select #交接
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 交接量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('DELIVERY_TICKET_CREATION_SCAN')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y%m%d')=date_sub(curdate(),interval 1 day)
        group by 1
    )pr3 on pr3.`store_id`=ss.`id`
left join
    (
        select #应盘
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应盘点量
        from
            (
                select #最后一条有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`state`
                    ,pr.`routed_at`
                from
                    (
                        select
                             pr.`pno`
                             ,pr.store_id
                             ,pr.`state`
                             ,pr.`routed_at`
                             ,row_number() over(partition by pr.`pno` order by pr.`routed_at` desc) as rn
                        from `ph_staging`.`parcel_route` pr
                        where
                            DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')<=date_sub(curdate(),interval 1 day)
                            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')>=date_sub(curdate(),interval 200 day)
                            and   pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                                           'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                                           'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                                           'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                     ) pr
                where pr.rn = 1
            ) pr
            left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
            left join
                (
                    select #车货关联出港
                        pr.`pno`
                        ,pr.`store_id`
                        ,pr.`routed_at`
                    from `ph_staging`.`parcel_route` pr
                    where
                        pr.`route_action` in ( 'DEPARTURE_GOODS_VAN_CK_SCAN')
                        and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')<=date_sub(curdate(),interval 1 day)
                        and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')>=date_sub(curdate(),interval 200 day)
                )pr1 on pr.pno=pr1.pno and pr.`store_id` =pr1.`store_id` and pr1.`routed_at`> pr.`routed_at`
        where
            pr1.pno is null
            and pi.state in (1,2,3,4,6)
        group by 1
    )pr4 on pr4.`store_id`=ss.`id`
left join
    (
        select #实际盘点
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实际盘点量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('INVENTORY','DETAIN_WAREHOUSE','DISTRIBUTION_INVENTORY','SORTING_SCAN')
            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
        GROUP BY 1
    )pr5 on pr5.`store_id`=ss.`id`
left join
    (
        select #应集包
            pr.`store_id`
            ,count(distinct pr.`pno`) 应集包量
        from `ph_staging`.`parcel_route` pr
        left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
        left join ph_staging.parcel_route pr2 on pr2.pno = pr.pno and pr2.route_action = 'UNSEAL' and DATE_FORMAT(CONVERT_TZ(pr2.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day) and pr2.store_id = pr.store_id
        where
            pr.`route_action` in ('SHIPMENT_WAREHOUSE_SCAN')
            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y%m%d')=date_sub(curdate(),interval 1 day)
            and pi.`exhibition_weight`<=3000
            and (pi.`exhibition_length` +pi.`exhibition_width` +pi.`exhibition_height`)<=60
            and pi.`exhibition_length` <=30
            and pi.`exhibition_width` <=30
            and pi.`exhibition_height` <=30
            and pr2.pno is not null
        GROUP BY 1
    )pr6 on pr6.`store_id`=ss.`id`
left join
    (
        select #实际集包
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实际集包量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ( 'SEAL')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y%m%d')=date_sub(curdate(),interval 1 day)
        group by 1
    )pr7 on pr7.`store_id`=ss.`id`
group by 1,2,3,4
order by 2;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    date_sub(curdate(),interval 1 day) 日期
    ,ss.`name` 网点名称
    ,smr.`name` 大区
    ,smp.`name` 片区
    ,v2.出勤收派员人数
    ,v2.出勤仓管人数
    ,v2.出勤主管人数
    ,pr.妥投量
    ,pr1.应到量
    ,pr2.实到量
    ,concat(round(pr2.实到量/pr1.应到量,4)*100,'%') 到件入仓率
    ,dc.应派量
    ,pr3.交接量
    ,concat(round(pr3.交接量/dc.应派量,4)*100,'%') 交接率
    ,pr4.应盘点量
    ,pr5.实际盘点量
    ,pr4.应盘点量- pr5.实际盘点量 未盘点量
    ,concat(round(pr5.实际盘点量/pr4.应盘点量,4)*100,'%') 盘点率
    ,pr6.应集包量
    ,pr7.实际集包量
    ,concat(round(pr7.实际集包量/pr6.应集包量,4)*100,'%') 集包率
from
    (
        select
            *
        from `ph_staging`.`sys_store` ss
        where
            ss.category in (8,12)
            and ss.state = 1
    ) ss
left join `ph_staging`.`sys_manage_region` smr on smr.`id`  =ss.`manage_region`
left join `ph_staging`.`sys_manage_piece` smp on smp.`id`  =ss.`manage_piece`
left join
    (
        select #出勤
            hi.`sys_store_id`
            ,count(distinct(if(v2.`job_title` in (13,110,807,1000),v2.`staff_info_id`,null))) 出勤收派员人数
            ,count(distinct(if(v2.`job_title` in (37),v2.`staff_info_id`,null))) 出勤仓管人数
            ,count(distinct(if(v2.`job_title` in (16,272),v2.`staff_info_id`,null))) 出勤主管人数
        from `ph_bi`.`attendance_data_v2` v2
        left join `ph_bi`.`hr_staff_info` hi on hi.`staff_info_id` =v2.`staff_info_id`
        where
            v2.`stat_date`=date_sub(curdate(),interval 1 day)
            and
                (v2.`attendance_started_at` is not null or v2.`attendance_end_at` is not null)
        group by 1
    )v2 on v2.`sys_store_id`=ss.`id`
left join
    (
        select #妥投
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 妥投量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('DELIVERY_CONFIRM')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') = date_sub(curdate(),interval 1 day)
        group by 1
    )pr on pr.`store_id`=ss.`id`
LEFT JOIN
    (
        select #应到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应到量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') = date_sub(curdate(),interval 1 day)
        group by 1
    )pr1 on pr1.`store_id`=ss.`id`
left join
    (
        select #实到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实到量
        from
            (
                select #车货关联到港
                    pr.`pno`
                    ,pr.`store_id`
                    ,pr.`routed_at`
                from `ph_staging`.`parcel_route` pr
                where
                    pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
                    and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
            )pr
        join
            (
                select #有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`routed_at`
                    ,pr.route_action
                    ,pr.store_name
                    ,pr.staff_info_id
                    ,pr.staff_info_phone
                    ,pr.staff_info_name
                    ,pr.extra_value
                from `ph_staging`.`parcel_route` pr
                where
                    pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                       'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                       'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                       'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                    and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') >= date_sub(curdate(),interval 1 day)
            ) pr1 on pr1.pno = pr.`pno`
        where
            pr1.store_id=pr.store_id
            and pr1.`routed_at`<= date_add(pr.`routed_at`,interval 4 hour)
        group by 1
    )pr2 on  pr2.`store_id`=ss.`id`
left join
    (
        select #应派
            dc.`store_id`
            ,count(distinct(dc.`pno`)) 应派量
        from `ph_bi`.`dc_should_delivery_today` dc
        where
            dc.`stat_date`= date_sub(curdate(),interval 1 day)
        group by 1
    ) dc on dc.`store_id`=ss.`id`
left join
    (
        select #交接
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 交接量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('DELIVERY_TICKET_CREATION_SCAN')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y-%m-%d')=date_sub(curdate(),interval 1 day)
        group by 1
    )pr3 on pr3.`store_id`=ss.`id`
left join
    (
        select #应盘
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应盘点量
        from
            (
                select #最后一条有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`state`
                    ,pr.`routed_at`
                from
                    (
                        select
                             pr.`pno`
                             ,pr.store_id
                             ,pr.`state`
                             ,pr.`routed_at`
                             ,row_number() over(partition by pr.`pno` order by pr.`routed_at` desc) as rn
                        from `ph_staging`.`parcel_route` pr
                        where
                            DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')<=date_sub(curdate(),interval 1 day)
                            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')>=date_sub(curdate(),interval 200 day)
                            and   pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                                           'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                                           'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                                           'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                     ) pr
                where pr.rn = 1
            ) pr
            left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
            left join
                (
                    select #车货关联出港
                        pr.`pno`
                        ,pr.`store_id`
                        ,pr.`routed_at`
                    from `ph_staging`.`parcel_route` pr
                    where
                        pr.`route_action` in ( 'DEPARTURE_GOODS_VAN_CK_SCAN')
                        and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')<=date_sub(curdate(),interval 1 day)
                        and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')>=date_sub(curdate(),interval 200 day)
                )pr1 on pr.pno=pr1.pno and pr.`store_id` =pr1.`store_id` and pr1.`routed_at`> pr.`routed_at`
        where
            pr1.pno is null
            and pi.state in (1,2,3,4,6)
        group by 1
    )pr4 on pr4.`store_id`=ss.`id`
left join
    (
        select #实际盘点
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实际盘点量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('INVENTORY','DETAIN_WAREHOUSE','DISTRIBUTION_INVENTORY','SORTING_SCAN')
            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
        GROUP BY 1
    )pr5 on pr5.`store_id`=ss.`id`
left join
    (
        select #应集包
            pr.`store_id`
            ,count(distinct pr.`pno`) 应集包量
        from `ph_staging`.`parcel_route` pr
        left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
        left join ph_staging.parcel_route pr2 on pr2.pno = pr.pno and pr2.route_action = 'UNSEAL' and DATE_FORMAT(CONVERT_TZ(pr2.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day) and pr2.store_id = pr.store_id
        where
            pr.`route_action` in ('SHIPMENT_WAREHOUSE_SCAN')
            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
            and pi.`exhibition_weight`<=3000
            and (pi.`exhibition_length` +pi.`exhibition_width` +pi.`exhibition_height`)<=60
            and pi.`exhibition_length` <=30
            and pi.`exhibition_width` <=30
            and pi.`exhibition_height` <=30
            and pr2.pno is not null
        GROUP BY 1
    )pr6 on pr6.`store_id`=ss.`id`
left join
    (
        select #实际集包
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实际集包量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ( 'SEAL')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
        group by 1
    )pr7 on pr7.`store_id`=ss.`id`
group by 1,2,3,4
order by 2;
;-- -. . -..- - / . -. - .-. -.--
select #实际集包
            pr.`store_id`
            ,count(distinctpr.`pno`) 实际集包量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ( 'SEAL')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
        group by 1;
;-- -. . -..- - / . -. - .-. -.--
select #实际集包
            pr.`store_id`
            ,count(distinct pr.`pno`) 实际集包量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ( 'SEAL')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
        group by 1;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    hub_name
   , to_date (van_arrive_phtime) AS '到港日期'
    ,SUM (hub_should_seal) AS '应该集包包裹量'
    ,SUM(IF (hub_should_seal = 1 AND seal_phtime IS NOT NULL, 1, 0)) AS '应集包且实际集包的总包裹量'
    ,SUM(IF (hub_should_seal = 1  AND seal_phtime IS NOT NULL, 1, 0))/ SUM (hub_should_seal) AS '集包率'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1, 1, 0)) AS '应拆包并集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1 AND seal_phtime IS NOT NULL, 1, 0)) AS '实际拆包并集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1 AND seal_phtime IS NOT NULL, 1, 0))/ SUM (IF (hub_should_seal = 1 AND should_unseal = 1, 1, 0)) AS '集包率'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0, 1, 0)) AS '应直接集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0 AND seal_phtime IS NOT NULL, 1, 0)) AS '实际直接集包包裹数'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0 AND seal_phtime IS NOT NULL, 1, 0))/ SUM (IF (hub_should_seal = 1 AND should_unseal = 0, 1, 0)) AS '集包率'
FROM
    (
        SELECT
            pi.pno
            , pss.store_name AS 'hub_name'
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11, 1, 0) AS 'if_store_should_seal', date_add (pss.van_arrived_at, INTERVAL
                    8 HOUR) AS 'van_arrive_phtime'
            , pss.arrival_pack_no
            , pack.es_unseal_store_name
            ,IF (pss.store_id = pack.es_unseal_store_id, 1, 0) AS 'should_unseal'
    -- 包裹本身应该集包，来的时候不是集包件或应拆包HUB是这个HUB，这个HUB就应该做集包
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11
                 AND (arrival_pack_no IS NULL OR pack.es_unseal_store_id = pss.store_id),1, 0) AS 'hub_should_seal'、
            , date_add (pss.sealed_at, INTERVAL 8 HOUR) AS 'seal_phtime'
        FROM ph_staging.parcel_info pi
        JOIN dw_dmd.parcel_store_stage_new pss  ON pss.van_arrived_at >= date_add (CURRENT_DATE() , INTERVAL -24-8 HOUR) AND pss.van_arrived_at < date_add (CURRENT_DATE() , INTERVAL -8 HOUR)
            AND pi.pno = pss.pno
            AND pss.store_category IN (8, 12)
            AND pss.store_name != '66 BAG_HUB_Maynila'
            AND pss.store_name NOT REGEXP '^Air|^SEA'
        LEFT JOIN ph_staging.pack_info pack ON pss.arrival_pack_no = pack.pack_no
        WHERE
            1 = 1
            AND pi.state < 9
            AND pi.returned = 0
    )
GROUP BY 1, 2
ORDER BY 1, 2;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    hub_name
   , date (van_arrive_phtime) AS '到港日期'
    ,SUM (hub_should_seal) AS '应该集包包裹量'
    ,SUM(IF (hub_should_seal = 1 AND seal_phtime IS NOT NULL, 1, 0)) AS '应集包且实际集包的总包裹量'
    ,SUM(IF (hub_should_seal = 1  AND seal_phtime IS NOT NULL, 1, 0))/ SUM (hub_should_seal) AS '集包率'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1, 1, 0)) AS '应拆包并集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1 AND seal_phtime IS NOT NULL, 1, 0)) AS '实际拆包并集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1 AND seal_phtime IS NOT NULL, 1, 0))/ SUM (IF (hub_should_seal = 1 AND should_unseal = 1, 1, 0)) AS '集包率'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0, 1, 0)) AS '应直接集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0 AND seal_phtime IS NOT NULL, 1, 0)) AS '实际直接集包包裹数'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0 AND seal_phtime IS NOT NULL, 1, 0))/ SUM (IF (hub_should_seal = 1 AND should_unseal = 0, 1, 0)) AS '集包率'
FROM
    (
        SELECT
            pi.pno
            , pss.store_name AS 'hub_name'
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11, 1, 0) AS 'if_store_should_seal', date_add (pss.van_arrived_at, INTERVAL
                    8 HOUR) AS 'van_arrive_phtime'
            , pss.arrival_pack_no
            , pack.es_unseal_store_name
            ,IF (pss.store_id = pack.es_unseal_store_id, 1, 0) AS 'should_unseal'
    -- 包裹本身应该集包，来的时候不是集包件或应拆包HUB是这个HUB，这个HUB就应该做集包
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11
                 AND (arrival_pack_no IS NULL OR pack.es_unseal_store_id = pss.store_id),1, 0) AS 'hub_should_seal'、
            , date_add (pss.sealed_at, INTERVAL 8 HOUR) AS 'seal_phtime'
        FROM ph_staging.parcel_info pi
        JOIN dw_dmd.parcel_store_stage_new pss  ON pss.van_arrived_at >= date_add (CURRENT_DATE() , INTERVAL -24-8 HOUR) AND pss.van_arrived_at < date_add (CURRENT_DATE() , INTERVAL -8 HOUR)
            AND pi.pno = pss.pno
            AND pss.store_category IN (8, 12)
            AND pss.store_name != '66 BAG_HUB_Maynila'
            AND pss.store_name NOT REGEXP '^Air|^SEA'
        LEFT JOIN ph_staging.pack_info pack ON pss.arrival_pack_no = pack.pack_no
        WHERE
            1 = 1
            AND pi.state < 9
            AND pi.returned = 0
    )
GROUP BY 1, 2
ORDER BY 1, 2;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    hub_name
    ,date(van_arrive_phtime) AS '到港日期'
    ,SUM(hub_should_seal) AS '应该集包包裹量'
    ,SUM(IF (hub_should_seal = 1 AND seal_phtime IS NOT NULL, 1, 0)) AS '应集包且实际集包的总包裹量'
    ,SUM(IF (hub_should_seal = 1  AND seal_phtime IS NOT NULL, 1, 0))/ SUM(hub_should_seal) AS '集包率'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1, 1, 0)) AS '应拆包并集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1 AND seal_phtime IS NOT NULL, 1, 0)) AS '实际拆包并集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1 AND seal_phtime IS NOT NULL, 1, 0))/ SUM(IF (hub_should_seal = 1 AND should_unseal = 1, 1, 0)) AS '集包率'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0, 1, 0)) AS '应直接集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0 AND seal_phtime IS NOT NULL, 1, 0)) AS '实际直接集包包裹数'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0 AND seal_phtime IS NOT NULL, 1, 0))/ SUM(IF (hub_should_seal = 1 AND should_unseal = 0, 1, 0)) AS '集包率'
FROM
    (
        SELECT
            pi.pno
            , pss.store_name AS 'hub_name'
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11, 1, 0) AS 'if_store_should_seal', date_add (pss.van_arrived_at, INTERVAL
                    8 HOUR) AS 'van_arrive_phtime'
            , pss.arrival_pack_no
            , pack.es_unseal_store_name
            ,IF (pss.store_id = pack.es_unseal_store_id, 1, 0) AS 'should_unseal'
    -- 包裹本身应该集包，来的时候不是集包件或应拆包HUB是这个HUB，这个HUB就应该做集包
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11
                 AND (arrival_pack_no IS NULL OR pack.es_unseal_store_id = pss.store_id),1, 0) AS 'hub_should_seal'、
            , date_add (pss.sealed_at, INTERVAL 8 HOUR) AS 'seal_phtime'
        FROM ph_staging.parcel_info pi
        JOIN dw_dmd.parcel_store_stage_new pss  ON pss.van_arrived_at >= date_add (CURRENT_DATE() , INTERVAL -24-8 HOUR) AND pss.van_arrived_at < date_add (CURRENT_DATE() , INTERVAL -8 HOUR)
            AND pi.pno = pss.pno
            AND pss.store_category IN (8, 12)
            AND pss.store_name != '66 BAG_HUB_Maynila'
            AND pss.store_name NOT REGEXP '^Air|^SEA'
        LEFT JOIN ph_staging.pack_info pack ON pss.arrival_pack_no = pack.pack_no
        WHERE
            1 = 1
            AND pi.state < 9
            AND pi.returned = 0
    )
GROUP BY 1, 2
ORDER BY 1, 2;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    hub_name
    ,date(van_arrive_phtime) AS '到港日期'
    ,SUM(hub_should_seal) AS '应该集包包裹量'
    ,SUM(IF (hub_should_seal = 1 AND seal_phtime IS NOT NULL, 1, 0)) AS '应集包且实际集包的总包裹量'
    ,SUM(IF (hub_should_seal = 1  AND seal_phtime IS NOT NULL, 1, 0))/ SUM(hub_should_seal) AS '集包率'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1, 1, 0)) AS '应拆包并集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1 AND seal_phtime IS NOT NULL, 1, 0)) AS '实际拆包并集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1 AND seal_phtime IS NOT NULL, 1, 0))/ SUM(IF (hub_should_seal = 1 AND should_unseal = 1, 1, 0)) AS '集包率'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0, 1, 0)) AS '应直接集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0 AND seal_phtime IS NOT NULL, 1, 0)) AS '实际直接集包包裹数'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0 AND seal_phtime IS NOT NULL, 1, 0))/ SUM(IF (hub_should_seal = 1 AND should_unseal = 0, 1, 0)) AS '集包率'
FROM
    (
        SELECT
            pi.pno
            , pss.store_name AS 'hub_name'
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11, 1, 0) AS 'if_store_should_seal', date_add (pss.van_arrived_at, INTERVAL
                    8 HOUR) AS 'van_arrive_phtime'
            , pss.arrival_pack_no
            , pack.es_unseal_store_name
            ,IF (pss.store_id = pack.es_unseal_store_id, 1, 0) AS 'should_unseal'
    -- 包裹本身应该集包，来的时候不是集包件或应拆包HUB是这个HUB，这个HUB就应该做集包
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11
                 AND (arrival_pack_no IS NULL OR pack.es_unseal_store_id = pss.store_id),1, 0) AS 'hub_should_seal'、
            , date_add(pss.sealed_at, INTERVAL 8 HOUR) AS 'seal_phtime'
        FROM ph_staging.parcel_info pi
        JOIN dw_dmd.parcel_store_stage_new pss  ON pss.van_arrived_at >= date_add (CURRENT_DATE() , INTERVAL -24-8 HOUR) AND pss.van_arrived_at < date_add (CURRENT_DATE() , INTERVAL -8 HOUR)
            AND pi.pno = pss.pno
            AND pss.store_category IN (8, 12)
            AND pss.store_name != '66 BAG_HUB_Maynila'
            AND pss.store_name NOT REGEXP '^Air|^SEA'
        LEFT JOIN ph_staging.pack_info pack ON pss.arrival_pack_no = pack.pack_no
        WHERE
            1 = 1
            AND pi.state < 9
            AND pi.returned = 0
    )
GROUP BY 1, 2
ORDER BY 1, 2;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    hub_name
    ,date(van_arrive_phtime) AS '到港日期'
    ,SUM(hub_should_seal) AS '应该集包包裹量'
    ,SUM(IF (hub_should_seal = 1 AND seal_phtime IS NOT NULL, 1, 0)) AS '应集包且实际集包的总包裹量'
    ,SUM(IF (hub_should_seal = 1  AND seal_phtime IS NOT NULL, 1, 0))/ SUM(hub_should_seal) AS '集包率'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1, 1, 0)) AS '应拆包并集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1 AND seal_phtime IS NOT NULL, 1, 0)) AS '实际拆包并集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 1 AND seal_phtime IS NOT NULL, 1, 0))/ SUM(IF (hub_should_seal = 1 AND should_unseal = 1, 1, 0)) AS '集包率'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0, 1, 0)) AS '应直接集包的包裹量'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0 AND seal_phtime IS NOT NULL, 1, 0)) AS '实际直接集包包裹数'
    ,SUM(IF (hub_should_seal = 1 AND should_unseal = 0 AND seal_phtime IS NOT NULL, 1, 0))/ SUM(IF (hub_should_seal = 1 AND should_unseal = 0, 1, 0)) AS '集包率'
FROM
    (
        SELECT
            pi.pno
            , pss.store_name AS 'hub_name'
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11, 1, 0) AS 'if_store_should_seal', date_add (pss.van_arrived_at, INTERVAL
                    8 HOUR) AS 'van_arrive_phtime'
            , pss.arrival_pack_no
            , pack.es_unseal_store_name
            ,IF (pss.store_id = pack.es_unseal_store_id, 1, 0) AS 'should_unseal'
    -- 包裹本身应该集包，来的时候不是集包件或应拆包HUB是这个HUB，这个HUB就应该做集包
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11
                 AND (arrival_pack_no IS NULL OR pack.es_unseal_store_id = pss.store_id),1, 0) AS 'hub_should_seal'
            , date_add(pss.sealed_at, INTERVAL 8 HOUR) AS 'seal_phtime'
        FROM ph_staging.parcel_info pi
        JOIN dw_dmd.parcel_store_stage_new pss  ON pss.van_arrived_at >= date_add (CURRENT_DATE() , INTERVAL -24-8 HOUR) AND pss.van_arrived_at < date_add (CURRENT_DATE() , INTERVAL -8 HOUR)
            AND pi.pno = pss.pno
            AND pss.store_category IN (8, 12)
            AND pss.store_name != '66 BAG_HUB_Maynila'
            AND pss.store_name NOT REGEXP '^Air|^SEA'
        LEFT JOIN ph_staging.pack_info pack ON pss.arrival_pack_no = pack.pack_no
        WHERE
            1 = 1
            AND pi.state < 9
            AND pi.returned = 0
    )
GROUP BY 1, 2
ORDER BY 1, 2;
;-- -. . -..- - / . -. - .-. -.--
select date_sub(curdate(), 1);
;-- -. . -..- - / . -. - .-. -.--
select
    *
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = date_sub(curdate(), interval 1 day)
    where
        ph.parcel_discover_date = '{$date}';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25'
)
select
    a.unload_period
    ,b.area
    ,a.hno
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-03-25', interval substring_index(t.unload_period,'-',1) hour) time1
                    ,date_add('2023-03-25', interval substring_index(t.unload_period,'-',1) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = t.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a
left join
    (
        select
            sh.store_id
            ,case -- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-25'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25'
)
select
    a.unload_period
    ,b.area
    ,a.hno
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-03-25', interval substring_index(t.unload_period,'-',1) hour) time1
                    ,date_add('2023-03-25', interval substring_index(t.unload_period,'-',1) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = t.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a
left join
    (
        select
            sh.store_id
            ,case -- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-25'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25'
)
select
    a.unload_period
    ,b.area
    ,a.hno
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-03-25', interval substring_index(t.unload_period,'-',1) hour) time1
                    ,date_add('2023-03-25', interval substring_index(t.unload_period,'-',1) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a
left join
    (
        select
            sh.store_id
            ,case -- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-25'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25'
)
select
    a.unload_period
    ,b.area
    ,a.hno
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a
left join
    (
        select
            sh.store_id
            ,case -- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-25'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25'
)
select
    a.unload_period
#     ,b.area
    ,a.hno
#     ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a;
;-- -. . -..- - / . -. - .-. -.--
select  substring_index('2-4','-',1);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25'
)
select
    a.unload_period
    ,a.submit_store_id
#     ,b.area
    ,a.hno
#     ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25'
)
select
    a.unload_period
    ,a.submit_store_id
#     ,b.area
    ,a.hno
#     ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25'
)
select
    a.unload_period
    ,a.submit_store_id
#     ,b.area
    ,a.hno
#     ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a
left join
    (
        select
            sh.store_id
            ,case -- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-25'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25'
)
select
    a.unload_period
    ,a.submit_store_id
    ,b.area
    ,a.hno
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a
left join
    (
        select
            sh.store_id
            ,case -- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-25'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
select
            sh.store_id
            ,case -- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-25'
        group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-03-25'
    where
        ph.parcel_discover_date = '2023-03-25'
)
select
    a.unload_period
    ,a.submit_store_id
    ,b.area
    ,a.hno
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-25', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-25'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-04-03'
    where
        ph.parcel_discover_date = '2023-04-03'
)
select
    a.unload_period
    ,a.submit_store_id
    ,b.area
    ,a.hno
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-04-03'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-04-03'
    where
        ph.parcel_discover_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,b.area
#     ,a.hno
#     ,b.num
# from
#     (
#         select
#             ph.submit_store_name
#             ,ph.submit_store_id
#             ,a.unload_period
#             ,ph.hno
#         from ph_staging.parcel_headless ph
#         join
#             (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-04-03'
    where
        ph.parcel_discover_date = '2023-04-03'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
#     ,b.area
#     ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a;
;-- -. . -..- - / . -. - .-. -.--
select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-04-03'
        group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 0 then 'B'
                when 1 then 'B'
                when 1 then 'C'
                when 2 then 'C'
            end area
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-04-03'
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select * from ph_nbd.suspected_headless_parcel_detail_v1 sh where  sh.store_id = 'PH19280F01' and sh.arrival_date = '2023-04-23';
;-- -. . -..- - / . -. - .-. -.--
select * from ph_staging.parcel_headless ph where ph.parcel_discover_date = '2023-04-03' and ph.submit_store_id = 'PH19280F01';
;-- -. . -..- - / . -. - .-. -.--
select * from ph_nbd.suspected_headless_parcel_detail_v1 sh where  sh.store_id = 'PH19280F01' and sh.arrival_date = '2023-04-02';
;-- -. . -..- - / . -. - .-. -.--
select * from ph_staging.parcel_headless ph where ph.parcel_discover_date = '2023-04-02' and ph.submit_store_id = 'PH19280F01';
;-- -. . -..- - / . -. - .-. -.--
select * from ph_staging.parcel_headless ph where date(convert_tz(ph.created_at,'+00:00', '+08:00')) = '2023-04-02' and ph.submit_store_id = 'PH19280F01';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-04-03'
    where
        ph.parcel_discover_date = '2023-04-03'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour)
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-04-03'
        group by 1,2
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-04-03'
    where
        ph.parcel_discover_date = '2023-04-03';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-04-03'
    where
        ph.parcel_discover_date = '2023-04-03'
# )
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-04-03'
    where
        ph.parcel_discover_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-04-03'
    where
        ph.parcel_discover_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id and ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-04-03'
    where
        ph.parcel_discover_date = '2023-04-03'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ph.submit_store_id
        ,sh.unload_period
    from ph_staging.parcel_headless ph
    left join ph_nbd.suspected_headless_parcel_detail_v1 sh on ph.submit_store_id = sh.store_id and sh.arrival_date = '2023-04-03'
    where
        ph.parcel_discover_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.submit_store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.submit_store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
select * from ph_nbd.suspected_headless_parcel_detail_v1 sh where  sh.store_id = 'PH19280F01' and sh.arrival_date = '2023-04-03';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t
                group by 1,2
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour) and ph.created_at < date_sub(a.time2, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and ph.find_area_category regexp a.type;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
            ,a.type
            ,ph.find_area_category
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
            ,a.type
            ,ph.find_area_category
            ,
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type regexp ph.find_area_category;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
            ,a.type
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type regexp ph.find_area_category;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
            ,a.type
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type regexp cast(ph.find_area_category as int);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-03'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
            ,a.type
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-03'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-04-03'
        group by 1,2
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-04-03'
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-04-03'
        group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-03'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-03', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-04-03'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-02'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-02', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-02', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-04-02'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
#     ,b.area
#     ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
        group by 1,2,3,4
    ) a;
;-- -. . -..- - / . -. - .-. -.--
select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
            ,a.type
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
            ,a.type
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%');
;-- -. . -..- - / . -. - .-. -.--
select * from ph_nbd.suspected_headless_parcel_detail_v1 sh where  sh.store_id = 'PH19280F01' and sh.arrival_date = '2023-03-29';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
            ,a.time1
            ,a.time2
            ,a.type
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t

            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
#             ,ph.created_at
#             ,a.time1
#             ,a.time2
#             ,a.type
#             ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t

            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
#             ,ph.created_at
#             ,a.time1
#             ,a.time2
#             ,a.type
#             ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t

            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)

        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period
where
     a.type like  concat('%',b.area, '%');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
#             ,ph.created_at
#             ,a.time1
#             ,a.time2
            ,a.type
#             ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t

            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)

        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period
where
     a.type like  concat('%',b.area, '%');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
#             ,ph.created_at
#             ,a.time1
#             ,a.time2
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t

            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,case
                when t.parcel_type = 0 then '1,2'
                when t.parcel_type = 1 then '2,3'
                when t.parcel_type = 2 then '3'
            end type
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3,4
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period
where
     b.type like  concat('%',a.find_area_category, '%');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
#             ,ph.created_at
#             ,a.time1
#             ,a.time2
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t

            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,case
                when sh.parcel_type = 0 then '1,2'
                when sh.parcel_type = 1 then '2,3'
                when sh.parcel_type = 2 then '3'
            end type
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3,4
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period
where
     b.type like  concat('%',a.find_area_category, '%');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
#             ,ph.created_at
#             ,a.time1
#             ,a.time2
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t

            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,case
                when sh.parcel_type = 0 then '1,2'
                when sh.parcel_type = 1 then '2,3'
                when sh.parcel_type = 2 then '3'
            end type

            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period
where
     b.type like  concat('%',a.find_area_category, '%');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
#             ,ph.created_at
#             ,a.time1
#             ,a.time2
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t

            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like concat('%',ph.find_area_category, '%')
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period


            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
#             ,ph.created_at
#             ,a.time1
#             ,a.time2
            ,ph.find_area_category

        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,case
                        when t.parcel_type = 0 then '1'
                        when t.parcel_type = 1 then '2'
                        when t.parcel_type = 2 then '3'
                    end type
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                from t

            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like concat('%',ph.find_area_category, '%')
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type-- 上线前
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period


            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-04-02'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-04-02', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-04-02', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-04-02'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-28'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-28', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-28', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-28'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-28'
)
# select
#     a.unload_period
#     ,a.submit_store_id
#     ,a.hno
#     ,b.area
#     ,b.num
# from
#     (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-28', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-28', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
        group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-28'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-28', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-28', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
            and ph.state = 0
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-28'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,b.area
    ,b.num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2
                    ,case
                        when t.parcel_type = 0 then '1,2'
                        when t.parcel_type = 1 then '2,3'
                        when t.parcel_type = 2 then '3'
                    end type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
            and ph.state = 0
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2,3
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period;
;-- -. . -..- - / . -. - .-. -.--
select
            sh.store_id
#             ,case  sh.parcel_type
#                 when 0 then 'A'
#                 when 1 then 'B'
#                 when 2 then 'C'
#             end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select arrival_date,unload_period,store_id,parcel_type,count(pno)AS headless_count
from ph_nbd.suspected_headless_parcel_detail_v1
where arrival_date = '2023-03-29'
and store_id = 'PH19280F01'
group by unload_period, parcel_type;
;-- -. . -..- - / . -. - .-. -.--
select
        fp.p_date 日期
        ,ss.name 网点
        ,ss.id 网点ID
        ,fp.view_num 访问人次
    #     ,fp.view_staff_num uv
        ,fp.match_num 点击匹配量
        ,fp.search_num 点击搜索量
        ,fp.sucess_num 成功匹配量
    from
        (
            select
                json_extract(ext_info,'$.organization_id') store_id
                ,fp.p_date
                ,count(if(fp.event_type = 'screenView', fp.user_id, null)) view_num
                ,count(distinct if(fp.event_type = 'screenView', fp.user_id, null)) view_staff_num
                ,count(if(fp.event_type = 'click' and fp.button_id = 'search', fp.user_id, null)) search_num
                ,count(if(fp.event_type = 'click' and fp.button_id = 'match', fp.user_id, null)) match_num
                ,count(if(json_unquote(json_extract(ext_info,'$.matchResult')) = 'true', fp.user_id, null)) sucess_num
            from dwm.dwd_ph_sls_pro_flash_point fp
            where
                fp.p_date >= '2023-03-01'
            group by 1,2
        ) fp
    left join ph_staging.sys_store ss on ss.id = fp.store_id
    where
        ss.category in (8,12);
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno
    ,ss3.name 揽收网点
    ,pr.next_store_name 揽收网点下一站
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
left join ph_staging.sys_store ss2 on if(ss.category in (8,12), ss.id, substring_index(ss.ancestry, '/', 1)) = ss2.id
left join ph_staging.sys_store ss3 on ss3.id = pi.ticket_pickup_store_id
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
where
    pi.created_at >= convert_tz('2023-04-10', '+08:00', '+00:00')
    and pi.created_at < convert_tz('2023-04-10', '+08:00', '+00:00')
    and ss2.id = 'PH14160302'  -- 99hub
    and ss3.category = 14;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pi.created_at, '+00:00', '+08:00')) 日期
    ,pi.pno
    ,ss3.name 揽收网点
    ,pr.next_store_name 揽收网点下一站
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
left join ph_staging.sys_store ss2 on if(ss.category in (8,12), ss.id, substring_index(ss.ancestry, '/', 1)) = ss2.id
left join ph_staging.sys_store ss3 on ss3.id = pi.ticket_pickup_store_id
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
where
    pi.created_at >= convert_tz('2023-04-01', '+08:00', '+00:00')
    and pi.created_at < convert_tz('2023-04-10', '+08:00', '+00:00')
    and ss2.id = 'PH14160302'  -- 99hub
    and ss3.category = 14;
;-- -. . -..- - / . -. - .-. -.--
select
    date(convert_tz(pi.created_at, '+00:00', '+08:00')) 日期
    ,pi.pno
    ,ss3.name 揽收网点
    ,pr.next_store_name 揽收网点下一站
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
left join ph_staging.sys_store ss2 on if(ss.category in (8,12), ss.id, substring_index(ss.ancestry, '/', 1)) = ss2.id -- 目的地hub
left join ph_staging.sys_store ss3 on ss3.id = pi.ticket_pickup_store_id -- 揽收网点
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.store_id = pi.ticket_pickup_store_id
where
    pi.created_at >= convert_tz('2023-04-01', '+08:00', '+00:00')
    and pi.created_at < convert_tz('2023-04-10', '+08:00', '+00:00')
    and ss2.id = 'PH14160302'  -- 99hub
    and ss3.category = 14;
;-- -. . -..- - / . -. - .-. -.--
select
    a.日期
    ,a.揽收网点
    ,count(if(a.next_store_id = 'PH14160302', a.pno, null)) 下一站99
    ,count(if(a.next_store_id != 'PH14160302', a.pno, null)) 下一站非99
from
    (
        select
            date(convert_tz(pi.created_at, '+00:00', '+08:00')) 日期
            ,pi.pno
            ,ss3.name 揽收网点
            ,pr.next_store_name 揽收网点下一站
            ,pr.next_store_id
        from ph_staging.parcel_info pi
        left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
        left join ph_staging.sys_store ss2 on if(ss.category in (8,12), ss.id, substring_index(ss.ancestry, '/', 1)) = ss2.id -- 目的地hub
        left join ph_staging.sys_store ss3 on ss3.id = pi.ticket_pickup_store_id -- 揽收网点
        left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.store_id = pi.ticket_pickup_store_id
        where
            pi.created_at >= convert_tz('2023-04-01', '+08:00', '+00:00')
            and pi.created_at < convert_tz('2023-04-10', '+08:00', '+00:00')
            and ss2.id = 'PH14160302'  -- 99hub
            and ss3.category = 14 -- PDC
            and pr.pno is not null
    ) a
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    a.日期
    ,a.揽收网点
    ,count(distinct if(a.next_store_id = 'PH14160302', a.pno, null)) 下一站99
    ,count(distinct if(a.next_store_id != 'PH14160302', a.pno, null)) 下一站非99
from
    (
        select
            date(convert_tz(pi.created_at, '+00:00', '+08:00')) 日期
            ,pi.pno
            ,ss3.name 揽收网点
            ,pr.next_store_name 揽收网点下一站
            ,pr.next_store_id
        from ph_staging.parcel_info pi
        left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
        left join ph_staging.sys_store ss2 on if(ss.category in (8,12), ss.id, substring_index(ss.ancestry, '/', 1)) = ss2.id -- 目的地hub
        left join ph_staging.sys_store ss3 on ss3.id = pi.ticket_pickup_store_id -- 揽收网点
        left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.store_id = pi.ticket_pickup_store_id
        where
            pi.created_at >= convert_tz('2023-04-01', '+08:00', '+00:00')
            and pi.created_at < convert_tz('2023-04-10', '+08:00', '+00:00')
            and ss2.id = 'PH14160302'  -- 99hub
            and ss3.category = 14 -- PDC
            and pr.pno is not null
    ) a
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    a.日期
    ,a.揽收网点
    ,count(distinct if(a.next_store_id = 'PH14160302', a.pno, null)) 下一站99
    ,count(distinct if(a.next_store_id != 'PH14160302', a.pno, null)) 下一站非99
from
    (
        select
            date(convert_tz(pi.created_at, '+00:00', '+08:00')) 日期
            ,pi.pno
            ,ss3.name 揽收网点
            ,pr.next_store_name 揽收网点下一站
            ,pr.next_store_id
        from ph_staging.parcel_info pi
        left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
        left join ph_staging.sys_store ss2 on if(ss.category in (8,12), ss.id, substring_index(ss.ancestry, '/', 1)) = ss2.id -- 目的地hub
        left join ph_staging.sys_store ss3 on ss3.id = pi.ticket_pickup_store_id -- 揽收网点
        left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.store_id = pi.ticket_pickup_store_id
        where
            pi.created_at >= convert_tz('2023-04-01', '+08:00', '+00:00')
            and pi.created_at < convert_tz('2023-04-11', '+08:00', '+00:00')
            and ss2.id = 'PH14160302'  -- 99hub
            and ss3.category = 14 -- PDC
            and pr.pno is not null
    ) a
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    a.日期
    ,a.揽收网点
    ,count(distinct if(a.next_store_id = 'PH14160302', a.pno, null)) 下一站99
    ,count(distinct if(a.next_store_id != 'PH14160302', a.pno, null)) 下一站非99
from
    (
        select
            date(convert_tz(pi.created_at, '+00:00', '+08:00')) 日期
            ,pi.pno
            ,ss3.name 揽收网点
            ,pr.next_store_name 揽收网点下一站
            ,pr.next_store_id
        from ph_staging.parcel_info pi
        left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
        left join ph_staging.sys_store ss2 on if(ss.category in (8,12), ss.id, substring_index(ss.ancestry, '/', 1)) = ss2.id -- 目的地hub
        left join ph_staging.sys_store ss3 on ss3.id = pi.ticket_pickup_store_id -- 揽收网点
        left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.store_id = pi.ticket_pickup_store_id
        where
            pi.created_at >= convert_tz('2023-04-01', '+08:00', '+00:00')
            and pi.created_at < convert_tz('2023-04-12', '+08:00', '+00:00')
            and ss2.id = 'PH14160302'  -- 99hub
            and ss3.category = 14 -- PDC
            and pr.pno is not null
    ) a
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
        ,case sh.parcel_type
            when 0 then '1,2'
            when 1 then '2,3'
            when 2 then '3'
        end type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,max(b.num) max_num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2

                    ,t.type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
            and ph.state = 0
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        sh.store_id
        ,sh.unload_period
        ,sh.pno
        ,sh.parcel_type
        ,case sh.parcel_type
            when 0 then '1,2'
            when 1 then '2,3'
            when 2 then '3'
        end type
    from ph_nbd.suspected_headless_parcel_detail_v1 sh
    where
        sh.arrival_date = '2023-03-29'
)
select
    a.unload_period
    ,a.submit_store_id
    ,a.hno
    ,max(b.num) max_num
from
    (
        select
            ph.submit_store_name
            ,ph.submit_store_id
            ,a.unload_period
            ,ph.hno
            ,ph.created_at
        from ph_staging.parcel_headless ph
        join
            (
                select
                    t.store_id
                    ,t.unload_period
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) hour) time1
                    ,date_add('2023-03-29', interval cast(substring_index(t.unload_period,'-',1) as int) + 24 hour) time2

                    ,t.type
                from t
            ) a on ph.submit_store_id = a.store_id
        where
            ph.created_at >= date_sub(a.time1, interval 8 hour)
            and ph.created_at < date_sub(a.time2, interval 8 hour)
            and a.type like  concat('%', ph.find_area_category, '%')
            and ph.state = 0
        group by 1,2,3,4
    ) a
left join
    (
        select
            sh.store_id
            ,case  sh.parcel_type
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2
    ) b on a.submit_store_id = b.store_id and a.unload_period = b.unload_period
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
select
            sh.store_id
            ,case  sh.parcel_type
                when 0 then 'A'
                when 1 then 'B'
                when 2 then 'C'
            end area
            ,sh.unload_period
            ,count(distinct sh.pno) num
        from ph_nbd.suspected_headless_parcel_detail_v1 sh
        where
            sh.arrival_date = '2023-03-29'
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    a.store_id
    ,date(a.van_arrive_phtime) AS '到港日期'
    ,SUM(a.hub_should_seal) AS '应该集包包裹量'
    ,SUM(IF (a.hub_should_seal = 1 AND a.seal_phtime IS NOT NULL, 1, 0)) AS '应集包且实际集包的总包裹量'
    ,SUM(IF (a.hub_should_seal = 1  AND a.seal_phtime IS NOT NULL, 1, 0))/ SUM(hub_should_seal) AS '集包率'
FROM
    (
        SELECT
            pi.pno
            , pss.store_name AS 'hub_name'
            ,pss.store_id
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11, 1, 0) AS 'if_store_should_seal', date_add (pss.van_arrived_at, INTERVAL
                    8 HOUR) AS 'van_arrive_phtime'
            , pss.arrival_pack_no
            , pack.es_unseal_store_name
            ,IF (pss.store_id = pack.es_unseal_store_id, 1, 0) AS 'should_unseal'
    -- 包裹本身应该集包，来的时候不是集包件或应拆包HUB是这个HUB，这个HUB就应该做集包
            ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11
                 AND (arrival_pack_no IS NULL OR pack.es_unseal_store_id = pss.store_id),1, 0) AS 'hub_should_seal'
            , date_add(pss.sealed_at, INTERVAL 8 HOUR) AS 'seal_phtime'
        FROM ph_staging.parcel_info pi
        JOIN dw_dmd.parcel_store_stage_new pss  ON pss.van_arrived_at >= date_add (CURRENT_DATE() , INTERVAL -24-8 HOUR) AND pss.van_arrived_at < date_add (CURRENT_DATE() , INTERVAL -8 HOUR)
            AND pi.pno = pss.pno
            AND pss.store_category IN (8, 12)
            AND pss.store_name != '66 BAG_HUB_Maynila'
            AND pss.store_name NOT REGEXP '^Air|^SEA'
        LEFT JOIN ph_staging.pack_info pack ON pss.arrival_pack_no = pack.pack_no
        WHERE
            1 = 1
            AND pi.state < 9
            AND pi.returned = 0
    ) a
GROUP BY 1, 2
ORDER BY 1, 2;
;-- -. . -..- - / . -. - .-. -.--
SELECT
    date_sub(curdate(),interval 1 day) 日期
    ,ss.`name` 网点名称
    ,smr.`name` 大区
    ,smp.`name` 片区
    ,v2.出勤收派员人数
    ,v2.出勤仓管人数
    ,v2.出勤主管人数
    ,pr.妥投量
    ,pr1.应到量
    ,pr2.实到量
    ,concat(round(pr2.实到量/pr1.应到量,4)*100,'%') 到件入仓率
    ,dc.应派量
    ,pr3.交接量
    ,concat(round(pr3.交接量/dc.应派量,4)*100,'%') 交接率
    ,pr4.应盘点量
    ,pr5.实际盘点量
    ,pr4.应盘点量- pr5.实际盘点量 未盘点量
    ,concat(round(pr5.实际盘点量/pr4.应盘点量,4)*100,'%') 盘点率
    ,seal.应该集包包裹量
    ,seal.应集包且实际集包的总包裹量 实际集包量
    ,seal.集包率 集包率
from
    (
        select
            *
        from `ph_staging`.`sys_store` ss
        where
            ss.category in (8,12)
    ) ss
left join `ph_staging`.`sys_manage_region` smr on smr.`id`  =ss.`manage_region`
left join `ph_staging`.`sys_manage_piece` smp on smp.`id`  =ss.`manage_piece`
left join
    (
        select #出勤
            hi.`sys_store_id`
            ,count(distinct(if(v2.`job_title` in (13,110,807,1000),v2.`staff_info_id`,null))) 出勤收派员人数
            ,count(distinct(if(v2.`job_title` in (37),v2.`staff_info_id`,null))) 出勤仓管人数
            ,count(distinct(if(v2.`job_title` in (16,272),v2.`staff_info_id`,null))) 出勤主管人数
        from `ph_bi`.`attendance_data_v2` v2
        left join `ph_bi`.`hr_staff_info` hi on hi.`staff_info_id` =v2.`staff_info_id`
        where
            v2.`stat_date`=date_sub(curdate(),interval 1 day)
            and
                (v2.`attendance_started_at` is not null or v2.`attendance_end_at` is not null)
        group by 1
    )v2 on v2.`sys_store_id`=ss.`id`
left join
    (
        select #妥投
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 妥投量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('DELIVERY_CONFIRM')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') = date_sub(curdate(),interval 1 day)
        group by 1
    )pr on pr.`store_id`=ss.`id`
LEFT JOIN
    (
        select #应到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应到量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') = date_sub(curdate(),interval 1 day)
        group by 1
    )pr1 on pr1.`store_id`=ss.`id`
left join
    (
        select #实到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实到量
        from
            (
                select #车货关联到港
                    pr.`pno`
                    ,pr.`store_id`
                    ,pr.`routed_at`
                from `ph_staging`.`parcel_route` pr
                where
                    pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
                    and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
            )pr
        join
            (
                select #有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`routed_at`
                    ,pr.route_action
                    ,pr.store_name
                    ,pr.staff_info_id
                    ,pr.staff_info_phone
                    ,pr.staff_info_name
                    ,pr.extra_value
                from `ph_staging`.`parcel_route` pr
                where
                    pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                       'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                       'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                       'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                    and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') >= date_sub(curdate(),interval 1 day)
            ) pr1 on pr1.pno = pr.`pno`
        where
            pr1.store_id=pr.store_id
            and pr1.`routed_at`<= date_add(pr.`routed_at`,interval 4 hour)
        group by 1
    )pr2 on  pr2.`store_id`=ss.`id`
left join
    (
        select #应派
            dc.`store_id`
            ,count(distinct(dc.`pno`)) 应派量
        from `ph_bi`.`dc_should_delivery_today` dc
        where
            dc.`stat_date`= date_sub(curdate(),interval 1 day)
        group by 1
    ) dc on dc.`store_id`=ss.`id`
left join
    (
        select #交接
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 交接量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('DELIVERY_TICKET_CREATION_SCAN')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y-%m-%d')=date_sub(curdate(),interval 1 day)
        group by 1
    )pr3 on pr3.`store_id`=ss.`id`
left join
    (
        select #应盘
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应盘点量
        from
            (
                select #最后一条有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`state`
                    ,pr.`routed_at`
                from
                    (
                        select
                             pr.`pno`
                             ,pr.store_id
                             ,pr.`state`
                             ,pr.`routed_at`
                             ,row_number() over(partition by pr.`pno` order by pr.`routed_at` desc) as rn
                        from `ph_staging`.`parcel_route` pr
                        where
                            DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')<=date_sub(curdate(),interval 1 day)
                            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')>=date_sub(curdate(),interval 200 day)
                            and   pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                                           'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                                           'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                                           'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                     ) pr
                where pr.rn = 1
            ) pr
            left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
            left join
                (
                    select #车货关联出港
                        pr.`pno`
                        ,pr.`store_id`
                        ,pr.`routed_at`
                    from `ph_staging`.`parcel_route` pr
                    where
                        pr.`route_action` in ( 'DEPARTURE_GOODS_VAN_CK_SCAN')
                        and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')<=date_sub(curdate(),interval 1 day)
                        and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')>=date_sub(curdate(),interval 200 day)
                )pr1 on pr.pno=pr1.pno and pr.`store_id` =pr1.`store_id` and pr1.`routed_at`> pr.`routed_at`
        where
            pr1.pno is null
            and pi.state in (1,2,3,4,6)
        group by 1
    )pr4 on pr4.`store_id`=ss.`id`
left join
    (
        select #实际盘点
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实际盘点量
        from `ph_staging`.`parcel_route` pr
        where
            pr.`route_action` in ('INVENTORY','DETAIN_WAREHOUSE','DISTRIBUTION_INVENTORY','SORTING_SCAN')
            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
        GROUP BY 1
    )pr5 on pr5.`store_id`=ss.`id`
left join
    (
        SELECT
            a.store_id
            ,date(a.van_arrive_phtime) AS '到港日期'
            ,SUM(a.hub_should_seal) AS '应该集包包裹量'
            ,SUM(IF (a.hub_should_seal = 1 AND a.seal_phtime IS NOT NULL, 1, 0)) AS '应集包且实际集包的总包裹量'
            ,SUM(IF (a.hub_should_seal = 1  AND a.seal_phtime IS NOT NULL, 1, 0))/ SUM(hub_should_seal) AS '集包率'
        FROM
            (
                SELECT
                    pi.pno
                    , pss.store_name AS 'hub_name'
                    ,pss.store_id
                    ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11, 1, 0) AS 'if_store_should_seal', date_add (pss.van_arrived_at, INTERVAL
                            8 HOUR) AS 'van_arrive_phtime'
                    , pss.arrival_pack_no
                    , pack.es_unseal_store_name
                    ,IF (pss.store_id = pack.es_unseal_store_id, 1, 0) AS 'should_unseal'
            -- 包裹本身应该集包，来的时候不是集包件或应拆包HUB是这个HUB，这个HUB就应该做集包
                    ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11
                         AND (arrival_pack_no IS NULL OR pack.es_unseal_store_id = pss.store_id),1, 0) AS 'hub_should_seal'
                    , date_add(pss.sealed_at, INTERVAL 8 HOUR) AS 'seal_phtime'
                FROM ph_staging.parcel_info pi
                JOIN dw_dmd.parcel_store_stage_new pss  ON pss.van_arrived_at >= date_add (CURRENT_DATE() , INTERVAL -24-8 HOUR) AND pss.van_arrived_at < date_add (CURRENT_DATE() , INTERVAL -8 HOUR)
                    AND pi.pno = pss.pno
                    AND pss.store_category IN (8, 12)
                    AND pss.store_name != '66 BAG_HUB_Maynila'
                    AND pss.store_name NOT REGEXP '^Air|^SEA'
                LEFT JOIN ph_staging.pack_info pack ON pss.arrival_pack_no = pack.pack_no
                WHERE
                    1 = 1
                    AND pi.state < 9
                    AND pi.returned = 0
            ) a
        GROUP BY 1, 2
        ORDER BY 1, 2
    ) seal on seal.store_id = ss.id
group by 1,2,3,4
order by 2;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from ph_bi.abnormal_customer_complaint acc
where
    acc.work_id is not null
limit 20;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,case
        when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
        when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
        when hsi.`state`=2 then '离职'
        when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,convert_tz(mw.created_at,'+00:00','+08:00') created_at
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
        ,ROW_NUMBER ()over(partition by hsi.staff_info_id order by mw.created_at ) rn
        ,count(mw.id) over (partition by hsi.staff_info_id) ct
    from
    (
             select
                mw.staff_info_id
            from ph_backyard.message_warning mw
            where
                mw.type_code = 'warning_27'
                and mw.operator_id = 87166
#             and mw.created_at >=convert_tz('2023-04-13','+08:00','+00:00')
            group by 1
    )ws
    join ph_bi.hr_staff_info hsi  on ws.staff_info_id=hsi.staff_info_id
    left join  ph_backyard.message_warning mw on hsi.staff_info_id =mw.staff_info_id and  mw.is_delete =0
    left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
    left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
    left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
    where
        hsi.state <> 2
)

select 
    t.staff_info_id 员工id
    ,t. 在职状态
    ,t.所属网点
    ,t.大区
    ,t.片区
    ,t.ct 警告次数
    ,t.created_at 第一次警告信时间
    ,t.警告原因 第一次警告原因
    ,t.警告类型 第一次警告类型
    ,t2.created_at 第二次警告信时间
    ,t2.警告原因 第二次警告原因
    ,t2.警告类型 第二次警告类型
    ,t3.created_at 第三次警告信时间
    ,t3.警告原因 第三次警告原因
    ,t3.警告类型 第三次警告类型
    ,t4.created_at 第四次警告信时间
    ,t4.警告原因 第四次警告原因
    ,t4.警告类型 第四次警告类型
    ,t5.created_at 第五次警告信时间
    ,t5.警告原因 第五次警告原因
    ,t5.警告类型 第五次警告类型
from t 
left join t t2 on t.staff_info_id=t2.staff_info_id and t2.rn=2
left join t t3 on t.staff_info_id=t3.staff_info_id and t3.rn=3
left join t t4 on t.staff_info_id=t4.staff_info_id and t4.rn=4
left join t t5 on t.staff_info_id=t5.staff_info_id and t5.rn=5
where
    t.rn=1;
;-- -. . -..- - / . -. - .-. -.--
select DATE_SUB(CURDATE(), INTERVAL 1 MONTH);
;-- -. . -..- - / . -. - .-. -.--
select  DATE_ADD(curdate(),interval -day(curdate())+1 day);
;-- -. . -..- - / . -. - .-. -.--
select
    swm.date_at
    ,count(distinct swm.id) 录入警告通知量
    ,count(distinct mw.id) 发警告书量
    ,count(distinct mw.id)/count(distinct swm.id) 警告占比
from ph_backyard.staff_warning_message swm
left join ph_backyard.message_warning mw on mw.staff_warning_message_id = swm.id
where
    swm.type = 1 -- 派件低效
    and swm.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,case
        when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
        when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
        when hsi.`state`=2 then '离职'
        when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join  ph_backyard.message_warning mw on hsi.staff_info_id =mw.staff_info_id and  mw.is_delete =0
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
    mw.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
    and mw.type_code = 'warning_27';
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join  ph_backyard.message_warning mw on hsi.staff_info_id =mw.staff_info_id and  mw.is_delete =0
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
    mw.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
    and mw.type_code = 'warning_27';
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
    mw.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
    and mw.type_code = 'warning_27'
    and mw.is_delete = 0;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
left join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
    mw.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
    and mw.type_code = 'warning_27'
    and mw.is_delete = 0;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,swm.date_at 违规日期
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
left join ph_backyard.staff_warning_message swm on swm.id = mw.staff_warning_message_id
left join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
    swm.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
    and mw.type_code = 'warning_27'
    and mw.is_delete = 0;
;-- -. . -..- - / . -. - .-. -.--
SELECT wo.`order_no` `工单编号`,
case wo.status
     when 1 then '未阅读'
     when 2 then '已经阅读'
     when 3 then '已回复'
     when 4 then '已关闭'
     end '工单状态',
pi.`client_id`  '客户ID',
wo.`pnos` '运单号',
case wo.order_type
          when 1 then '查找运单'
          when 2 then '加快处理'
          when 3 then '调查员工'
          when 4 then '其他'
          when 5 then '网点信息维护提醒'
          when 6 then '培训指导'
          when 7 then '异常业务询问'
          when 8 then '包裹丢失'
          when 9 then '包裹破损'
          when 10 then '货物短少'
          when 11 then '催单'
          when 12 then '有发无到'
          when 13 then '上报包裹不在集包里'
          when 16 then '漏揽收'
          when 50 then '虚假撤销'
          when 17 then '已签收未收到'
          when 18 then '客户投诉'
          when 19 then '修改包裹信息'
          when 20 then '修改 COD 金额'
          when 21 then '解锁包裹'
          when 22 then '申请索赔'
          when 23 then 'MS 问题反馈'
          when 24 then 'FBI 问题反馈'
          when 25 then 'KA System 问题反馈'
          when 26 then 'App 问题反馈'
          when 27 then 'KIT 问题反馈'
          when 28 then 'Backyard 问题反馈'
          when 29 then 'BS/FH 问题反馈'
          when 30 then '系统建议'
          when 31 then '申诉罚款'
          else wo.order_type
          end  '工单类型',
wo.`title` `工单标题`,
wo.`created_at` `工单创建时长`,
wor.`工单回复时间` `工单回复时间`,
wo.`created_staff_info_id` `发起人`,
wo.`closed_at` `工单关闭时间`,
wor.staff_info_id `回复人`,
ss1.name `创建网点名称`,
case
when ss1.`category` in (1,2,10,13) then 'sp'
              when ss1.`category` in (8,9,12) then 'HUB/BHUB/OS'
              when ss1.`category` IN (4,5,7) then 'SHOP/ushop'
              when ss1.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
              when wo.`created_store_id` in (3,'customer_manger') then  '总部客服中心'
              when wo.`created_store_id`= '12' then 'QA&QC'
              when wo.`created_store_id`= '18' then 'Flash Home客服中心'
              when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
              when wo.`created_store_id` = '20' then 'PRODUCT'
              else '客服中心'
              end `创建网点/部门 `,
ss.name `受理网点名称`,
case when ss.`category` in (1,2,10,13) then 'sp'
              when ss.`category` in (8,9,12) then 'HUB/BHUB/OS'
              when ss.`category` IN (4,5,7) then 'SHOP/ushop'
              when ss.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
              when wo.`store_id` in (3,'customer_manger') then  '总部客服中心'
              when wo.`store_id`= '12' then 'QA&QC'
              when wo.`store_id`= '18' then 'Flash Home客服中心'
              when wo.`store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
              when wo.`store_id` = '20' then 'PRODUCT'
              else '客服中心'
              end `受理网点/部门 `,
pi. `last_cn_route_action` `最后一步有效路由`,
pi.last_route_time `操作时间`,
pi.last_store_name `操作网点`,
pi.last_staff_info_id `操作人员`

from `ph_bi`.`work_order` wo
left join dwm.dwd_ex_ph_parcel_details pi
on wo.`pnos` =pi.`pno` and  pick_date>=date_sub(curdate(),interval 2 month)
left join
    (select order_id,staff_info_id ,max(created_at) `工单回复时间`
     from `ph_bi`.`work_order_reply`
     group by 1,2) wor
on  wor.`order_id`=wo.`id`

left join   `ph_bi`.`sys_store`  ss on ss.`id` =wo.`store_id`
left join   `ph_bi`.`sys_store`  ss1 on ss1.`id` =wo.`created_store_id`
where month(wo.`created_at`) =month(CURDATE());
;-- -. . -..- - / . -. - .-. -.--
SELECT
    date_sub(curdate(),interval 1 day) 日期
    ,ss.`name` 网点名称
    ,smr.`name` 大区
    ,smp.`name` 片区
    ,v2.出勤收派员人数
    ,v2.出勤仓管人数
    ,v2.出勤主管人数
    ,pr.妥投量
    ,pr1.应到量
    ,pr2.实到量
    ,concat(round(pr2.实到量/pr1.应到量,4)*100,'%') 到件入仓率
    ,dc.应派量
    ,pr3.交接量
    ,concat(round(pr3.交接量/dc.应派量,4)*100,'%') 交接率
    ,pr4.应盘点量
    ,pr5.实际盘点量
    ,pr4.应盘点量- pr5.实际盘点量 未盘点量
    ,concat(round(pr5.实际盘点量/pr4.应盘点量,4)*100,'%') 盘点率
    ,seal.应该集包包裹量
    ,seal.应集包且实际集包的总包裹量 实际集包量
    ,seal.集包率 集包率
from
    (
        select
            *
        from `ph_staging`.`sys_store` ss
        where
            ss.category in (8,12)
    ) ss
left join `ph_staging`.`sys_manage_region` smr on smr.`id`  =ss.`manage_region`
left join `ph_staging`.`sys_manage_piece` smp on smp.`id`  =ss.`manage_piece`
left join
    (
        select #出勤
            hi.`sys_store_id`
            ,count(distinct(if(v2.`job_title` in (13,110,807,1000),v2.`staff_info_id`,null))) 出勤收派员人数
            ,count(distinct(if(v2.`job_title` in (37),v2.`staff_info_id`,null))) 出勤仓管人数
            ,count(distinct(if(v2.`job_title` in (16,272),v2.`staff_info_id`,null))) 出勤主管人数
        from `ph_bi`.`attendance_data_v2` v2
        left join `ph_bi`.`hr_staff_info` hi on hi.`staff_info_id` =v2.`staff_info_id`
        join ph_staging.sys_store ss on ss.id = hi.sys_store_id and ss.category in (8,12)
        where
            v2.`stat_date`=date_sub(curdate(),interval 1 day)
            and
                (v2.`attendance_started_at` is not null or v2.`attendance_end_at` is not null)
        group by 1
    )v2 on v2.`sys_store_id`=ss.`id`
left join
    (
        select #妥投
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 妥投量
        from `ph_staging`.`parcel_route` pr
        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
        where
            pr.`route_action` in ('DELIVERY_CONFIRM')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') = date_sub(curdate(),interval 1 day)
        group by 1
    )pr on pr.`store_id`=ss.`id`
LEFT JOIN
    (
        select #应到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应到量
        from `ph_staging`.`parcel_route` pr
        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
        where
            pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') = date_sub(curdate(),interval 1 day)
        group by 1
    )pr1 on pr1.`store_id`=ss.`id`
left join
    (
        select #实到
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实到量
        from
            (
                select #车货关联到港
                    pr.`pno`
                    ,pr.`store_id`
                    ,pr.`routed_at`
                from `ph_staging`.`parcel_route` pr
                join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
                where
                    pr.`route_action` in ('ARRIVAL_GOODS_VAN_CHECK_SCAN')
                    and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
            )pr
        join
            (
                select #有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`routed_at`
                    ,pr.route_action
                    ,pr.store_name
                    ,pr.staff_info_id
                    ,pr.staff_info_phone
                    ,pr.staff_info_name
                    ,pr.extra_value
                from `ph_staging`.`parcel_route` pr
                join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
                where
                    pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                       'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                       'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                       'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                       'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                    and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d') >= date_sub(curdate(),interval 1 day)
            ) pr1 on pr1.pno = pr.`pno`
        where
            pr1.store_id=pr.store_id
            and pr1.`routed_at`<= date_add(pr.`routed_at`,interval 4 hour)
        group by 1
    )pr2 on  pr2.`store_id`=ss.`id`
left join
    (
        select #应派
            dc.`store_id`
            ,count(distinct(dc.`pno`)) 应派量
        from `ph_bi`.`dc_should_delivery_today` dc
        join ph_staging.sys_store ss on ss.id = dc.store_id and ss.category in (8,12)
        where
            dc.`stat_date`= date_sub(curdate(),interval 1 day)
        group by 1
    ) dc on dc.`store_id`=ss.`id`
left join
    (
        select #交接
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 交接量
        from `ph_staging`.`parcel_route` pr
        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
        where
            pr.`route_action` in ('DELIVERY_TICKET_CREATION_SCAN')
            and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y-%m-%d')=date_sub(curdate(),interval 1 day)
        group by 1
    )pr3 on pr3.`store_id`=ss.`id`
left join
    (
        select #应盘
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 应盘点量
        from
            (
                select #最后一条有效路由
                    pr.`pno`
                    ,pr.store_id
                    ,pr.`state`
                    ,pr.`routed_at`
                from
                    (
                        select
                             pr.`pno`
                             ,pr.store_id
                             ,pr.`state`
                             ,pr.`routed_at`
                             ,row_number() over(partition by pr.`pno` order by pr.`routed_at` desc) as rn
                        from `ph_staging`.`parcel_route` pr
                        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
                        where
                            DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')<=date_sub(curdate(),interval 1 day)
                            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')>=date_sub(curdate(),interval 200 day)
                            and   pr.`route_action` in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                                           'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                                           'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                                           'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                                           'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY')
                     ) pr
                where pr.rn = 1
            ) pr
            left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
            left join
                (
                    select #车货关联出港
                        pr.`pno`
                        ,pr.`store_id`
                        ,pr.`routed_at`
                    from `ph_staging`.`parcel_route` pr
                    join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
                    where
                        pr.`route_action` in ( 'DEPARTURE_GOODS_VAN_CK_SCAN')
                        and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')<=date_sub(curdate(),interval 1 day)
                        and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')>=date_sub(curdate(),interval 200 day)
                )pr1 on pr.pno=pr1.pno and pr.`store_id` =pr1.`store_id` and pr1.`routed_at`> pr.`routed_at`
        where
            pr1.pno is null
            and pi.state in (1,2,3,4,6)
        group by 1
    )pr4 on pr4.`store_id`=ss.`id`
left join
    (
        select #实际盘点
            pr.`store_id`
            ,count(distinct(pr.`pno`)) 实际盘点量
        from `ph_staging`.`parcel_route` pr
        join ph_staging.sys_store ss on ss.id = pr.store_id and ss.category in (8,12)
        where
            pr.`route_action` in ('INVENTORY','DETAIN_WAREHOUSE','DISTRIBUTION_INVENTORY','SORTING_SCAN')
            and DATE_FORMAT(CONVERT_TZ(pr.`routed_at`, '+00:00', '+08:00'),'%Y-%m-%d')=date_sub(curdate(),interval 1 day)
        GROUP BY 1
    )pr5 on pr5.`store_id`=ss.`id`
left join
    (
        SELECT
            a.store_id
            ,date(a.van_arrive_phtime) AS '到港日期'
            ,SUM(a.hub_should_seal) AS '应该集包包裹量'
            ,SUM(IF (a.hub_should_seal = 1 AND a.seal_phtime IS NOT NULL, 1, 0)) AS '应集包且实际集包的总包裹量'
            ,SUM(IF (a.hub_should_seal = 1  AND a.seal_phtime IS NOT NULL, 1, 0))/ SUM(hub_should_seal) AS '集包率'
        FROM
            (
                SELECT
                    pi.pno
                    , pss.store_name AS 'hub_name'
                    ,pss.store_id
                    ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11, 1, 0) AS 'if_store_should_seal', date_add (pss.van_arrived_at, INTERVAL
                            8 HOUR) AS 'van_arrive_phtime'
                    , pss.arrival_pack_no
                    , pack.es_unseal_store_name
                    ,IF (pss.store_id = pack.es_unseal_store_id, 1, 0) AS 'should_unseal'
            -- 包裹本身应该集包，来的时候不是集包件或应拆包HUB是这个HUB，这个HUB就应该做集包
                    ,IF (pi.exhibition_weight <= 3000 AND pi.exhibition_length <= 30 AND pi.exhibition_width <= 30 AND pi.exhibition_height <= 30 AND pi.exhibition_length + pi.exhibition_width + pi.exhibition_height <= 60 AND pi.article_category != 11
                         AND (arrival_pack_no IS NULL OR pack.es_unseal_store_id = pss.store_id),1, 0) AS 'hub_should_seal'
                    , date_add(pss.sealed_at, INTERVAL 8 HOUR) AS 'seal_phtime'
                FROM ph_staging.parcel_info pi
                JOIN dw_dmd.parcel_store_stage_new pss  ON pss.van_arrived_at >= date_add (CURRENT_DATE() , INTERVAL -24-8 HOUR) AND pss.van_arrived_at < date_add (CURRENT_DATE() , INTERVAL -8 HOUR)
                    AND pi.pno = pss.pno
                    AND pss.store_category IN (8, 12)
                    AND pss.store_name != '66 BAG_HUB_Maynila'
                    AND pss.store_name NOT REGEXP '^Air|^SEA'
                LEFT JOIN ph_staging.pack_info pack ON pss.arrival_pack_no = pack.pack_no
                WHERE
                    1 = 1
                    AND pi.state < 9
                    AND pi.returned = 0
            ) a
        GROUP BY 1, 2
        ORDER BY 1, 2
    ) seal on seal.store_id = ss.id
group by 1,2,3,4
order by 2;
;-- -. . -..- - / . -. - .-. -.--
select
    mw.date_ats
    ,count(distinct swm.id) 录入警告通知量
    ,count(distinct mw.id) 发警告书量
    ,count(distinct mw.id)/count(distinct swm.id) 警告占比
from ph_backyard.staff_warning_message swm
left join ph_backyard.message_warning mw on mw.staff_warning_message_id = swm.id
where
    swm.type = 1 -- 派件低效
    and swm.date_at >= date_add(curdate(),interval -day(curdate()) + 1 day)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    mw.date_ats
    ,count(distinct swm.id) 录入警告通知量
    ,count(distinct mw.id) 发警告书量
    ,count(distinct mw.id)/count(distinct swm.id) 警告占比
from ph_backyard.staff_warning_message swm
left join ph_backyard.message_warning mw on mw.staff_warning_message_id = swm.id
where
    swm.type = 1 -- 派件低效
    and mw.date_ats >= date_add(curdate(),interval -day(curdate()) + 1 day)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    swm.date_at
    ,count(distinct swm.id) 录入警告通知量
    ,count(distinct mw.id) 发警告书量
    ,count(distinct mw.id)/count(distinct swm.id) 警告占比
from ph_backyard.staff_warning_message swm
left join ph_backyard.message_warning mw on mw.staff_warning_message_id = swm.id
where
    swm.type = 1 -- 派件低效
    and swm.date_at >= date_add(curdate(),interval -day(curdate()) + 1 day)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    swm.date_at
    ,count(distinct swm.id) 录入警告通知量
    ,count(distinct if(swm.hr_fix_status = 0, swm.id, null)) 未处理量
    ,count(distinct mw.id) 发警告书量
    ,count(distinct mw.id)/count(distinct swm.id) 警告占比
from ph_backyard.staff_warning_message swm
left join ph_backyard.message_warning mw on mw.staff_warning_message_id = swm.id
where
    swm.type = 1 -- 派件低效
    and swm.date_at >= date_add(curdate(),interval -day(curdate()) + 1 day)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
SELECT wo.`order_no` `工单编号`,
case wo.status
     when 1 then '未阅读'
     when 2 then '已经阅读'
     when 3 then '已回复'
     when 4 then '已关闭'
     end '工单状态',
pi.`client_id`  '客户ID',
wo.`pnos` '运单号',
case wo.order_type
          when 1 then '查找运单'
          when 2 then '加快处理'
          when 3 then '调查员工'
          when 4 then '其他'
          when 5 then '网点信息维护提醒'
          when 6 then '培训指导'
          when 7 then '异常业务询问'
          when 8 then '包裹丢失'
          when 9 then '包裹破损'
          when 10 then '货物短少'
          when 11 then '催单'
          when 12 then '有发无到'
          when 13 then '上报包裹不在集包里'
          when 16 then '漏揽收'
          when 50 then '虚假撤销'
          when 17 then '已签收未收到'
          when 18 then '客户投诉'
          when 19 then '修改包裹信息'
          when 20 then '修改 COD 金额'
          when 21 then '解锁包裹'
          when 22 then '申请索赔'
          when 23 then 'MS 问题反馈'
          when 24 then 'FBI 问题反馈'
          when 25 then 'KA System 问题反馈'
          when 26 then 'App 问题反馈'
          when 27 then 'KIT 问题反馈'
          when 28 then 'Backyard 问题反馈'
          when 29 then 'BS/FH 问题反馈'
          when 30 then '系统建议'
          when 31 then '申诉罚款'
          else wo.order_type
          end  '工单类型',
wo.`title` `工单标题`,
wo.`created_at` `工单创建时长`,
wor.`工单回复时间` `工单回复时间`,
wo.`created_staff_info_id` `发起人`,
wo.`closed_at` `工单关闭时间`,
wor.staff_info_id `回复人`,
ss1.name `创建网点名称`,
case
when ss1.`category` in (1,2,10,13) then 'sp'
              when ss1.`category` in (8,9,12) then 'HUB/BHUB/OS'
              when ss1.`category` IN (4,5,7) then 'SHOP/ushop'
              when ss1.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
              when wo.`created_store_id` in (3,'customer_manger') then  '总部客服中心'
              when wo.`created_store_id`= '12' then 'QA&QC'
              when wo.`created_store_id`= '18' then 'Flash Home客服中心'
              when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
              when wo.`created_store_id` = '20' then 'PRODUCT'
              else '客服中心'
              end `创建网点/部门 `,
ss.name `受理网点名称`,
case when ss.`category` in (1,2,10,13) then 'sp'
              when ss.`category` in (8,9,12) then 'HUB/BHUB/OS'
              when ss.`category` IN (4,5,7) then 'SHOP/ushop'
              when ss.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
              when wo.`store_id` in (3,'customer_manger') then  '总部客服中心'
              when wo.`store_id`= '12' then 'QA&QC'
              when wo.`store_id`= '18' then 'Flash Home客服中心'
              when wo.`store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
              when wo.`store_id` = '20' then 'PRODUCT'
              else '客服中心'
              end `受理网点/部门 `,
pi. `last_cn_route_action` `最后一步有效路由`,
pi.last_route_time `操作时间`,
pi.last_store_name `操作网点`,
pi.last_staff_info_id `操作人员`

from `ph_bi`.`work_order` wo
left join dwm.dwd_ex_ph_parcel_details pi
on wo.`pnos` =pi.`pno` and  pick_date>=date_sub(curdate(),interval 2 month)
left join
    (select order_id,staff_info_id ,max(created_at) `工单回复时间`
     from `ph_bi`.`work_order_reply`
     group by 1,2) wor
on  wor.`order_id`=wo.`id`

left join   `ph_bi`.`sys_store`  ss on ss.`id` =wo.`store_id`
left join   `ph_bi`.`sys_store`  ss1 on ss1.`id` =wo.`created_store_id`
where wo.`created_at` >= date_add(curdate(),interval -day(curdate()) + 1 day);
;-- -. . -..- - / . -. - .-. -.--
SELECT wo.`order_no` `工单编号`,
case wo.status
     when 1 then '未阅读'
     when 2 then '已经阅读'
     when 3 then '已回复'
     when 4 then '已关闭'
     end '工单状态',
pi.`client_id`  '客户ID',
wo.`pnos` '运单号',
case wo.order_type
          when 1 then '查找运单'
          when 2 then '加快处理'
          when 3 then '调查员工'
          when 4 then '其他'
          when 5 then '网点信息维护提醒'
          when 6 then '培训指导'
          when 7 then '异常业务询问'
          when 8 then '包裹丢失'
          when 9 then '包裹破损'
          when 10 then '货物短少'
          when 11 then '催单'
          when 12 then '有发无到'
          when 13 then '上报包裹不在集包里'
          when 16 then '漏揽收'
          when 50 then '虚假撤销'
          when 17 then '已签收未收到'
          when 18 then '客户投诉'
          when 19 then '修改包裹信息'
          when 20 then '修改 COD 金额'
          when 21 then '解锁包裹'
          when 22 then '申请索赔'
          when 23 then 'MS 问题反馈'
          when 24 then 'FBI 问题反馈'
          when 25 then 'KA System 问题反馈'
          when 26 then 'App 问题反馈'
          when 27 then 'KIT 问题反馈'
          when 28 then 'Backyard 问题反馈'
          when 29 then 'BS/FH 问题反馈'
          when 30 then '系统建议'
          when 31 then '申诉罚款'
          else wo.order_type
          end  '工单类型',
wo.`title` `工单标题`,
wo.`created_at` `工单创建时长`,
wor.`工单回复时间` `工单回复时间`,
wo.`created_staff_info_id` `发起人`,
wo.`closed_at` `工单关闭时间`,
wor.staff_info_id `回复人`,
ss1.name `创建网点名称`,
case
when ss1.`category` in (1,2,10,13) then 'sp'
              when ss1.`category` in (8,9,12) then 'HUB/BHUB/OS'
              when ss1.`category` IN (4,5,7) then 'SHOP/ushop'
              when ss1.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
              when wo.`created_store_id` in (3,'customer_manger') then  '总部客服中心'
              when wo.`created_store_id`= '12' then 'QA&QC'
              when wo.`created_store_id`= '18' then 'Flash Home客服中心'
              when wo.`created_store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
              when wo.`created_store_id` = '20' then 'PRODUCT'
              else '客服中心'
              end `创建网点/部门 `,
ss.name `受理网点名称`,
case when ss.`category` in (1,2,10,13) then 'sp'
              when ss.`category` in (8,9,12) then 'HUB/BHUB/OS'
              when ss.`category` IN (4,5,7) then 'SHOP/ushop'
              when ss.`category` IN (6)  then 'FH'when wo.`store_id` = '22' then 'kam客服中心'
              when wo.`store_id` in (3,'customer_manger') then  '总部客服中心'
              when wo.`store_id`= '12' then 'QA&QC'
              when wo.`store_id`= '18' then 'Flash Home客服中心'
              when wo.`store_id` = '22' and wo.`client_id` IN ('AA0302','AA0413','AA0472','AA0545','BF9675','BF9690','CA5901' ) then 'FFM'
              when wo.`store_id` = '20' then 'PRODUCT'
              else '客服中心'
              end `受理网点/部门 `,
pi. `last_cn_route_action` `最后一步有效路由`,
pi.last_route_time `操作时间`,
pi.last_store_name `操作网点`,
pi.last_staff_info_id `操作人员`

from `ph_bi`.`work_order` wo
left join dwm.dwd_ex_ph_parcel_details pi
on wo.`pnos` =pi.`pno` and  pick_date>=date_sub(curdate(),interval 2 month)
left join
    (select order_id,staff_info_id ,max(created_at) `工单回复时间`
     from `ph_bi`.`work_order_reply`
     group by 1,2) wor
on  wor.`order_id`=wo.`id`

left join   `ph_bi`.`sys_store`  ss on ss.`id` =wo.`store_id`
left join   `ph_bi`.`sys_store`  ss1 on ss1.`id` =wo.`created_store_id`
where wo.`created_at` >= date_sub(curdate() , interval 31 day);
;-- -. . -..- - / . -. - .-. -.--
select
    date(swm.created_at) 录入日期
    ,count(distinct swm.id) 录入警告通知量
    ,count(distinct if(swm.hr_fix_status = 0, swm.id, null)) 未处理量
    ,count(distinct mw.id) 发警告书量
    ,count(distinct mw.id)/count(distinct swm.id) 警告占比
from ph_backyard.staff_warning_message swm
left join ph_backyard.message_warning mw on mw.staff_warning_message_id = swm.id
where
    swm.type = 1 -- 派件低效
    and swm.date_at >= date_add(curdate(),interval -day(curdate()) + 1 day)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    date(swm.created_at) 录入日期
    ,count(distinct swm.id) 录入警告通知量
    ,count(distinct if(swm.hr_fix_status = 0, swm.id, null)) HRBP未处理量
    ,count(distinct mw.id) 发警告书量
    ,count(distinct mw.id)/count(distinct swm.id) 警告占比
from ph_backyard.staff_warning_message swm
left join ph_backyard.message_warning mw on mw.staff_warning_message_id = swm.id
where
    swm.type = 1 -- 派件低效
    and swm.date_at >= date_add(curdate(),interval -day(curdate()) + 1 day)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,swm.date_at 违规日期
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
left join ph_backyard.staff_warning_message swm on swm.id = mw.staff_warning_message_id
left join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
#     swm.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
#     and mw.type_code = 'warning_27'
    mw.created_at >= '2023-03-01'
    and mw.created_at < '2023-04-01'
    and mw.is_delete = 0;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,mw.date_ats 违规日期
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
left join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
#     swm.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
#     and mw.type_code = 'warning_27'
    mw.created_at >= '2023-03-01'
    and mw.created_at < '2023-04-01'
    and mw.is_delete = 0;
;-- -. . -..- - / . -. - .-. -.--
select
    date(swm.created_at) 录入日期
    ,count(distinct swm.id) 录入警告通知量
    ,count(distinct if(swm.hr_fix_status = 0, swm.id, null)) HRBP未处理量
    ,count(distinct mw.id) 发警告书量
    ,count(distinct mw.id)/count(distinct swm.id) 警告占比
from ph_backyard.staff_warning_message swm
left join ph_backyard.message_warning mw on mw.staff_warning_message_id = swm.id
where
    swm.type = 1 -- 派件低效
    and swm.date_at >= date_add(curdate(),interval -day(curdate()) + 1 day)
group by 1
order by 1;
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.name 姓名
        ,hjt.job_name 职位
        ,case
            when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
            when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
            when hsi.`state`=2 then '离职'
            when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,mw.date_ats 违规日期
        ,convert_tz(mw.created_at,'+00:00','+08:00') 警告信发放时间
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
from ph_backyard.message_warning mw
left join ph_bi.hr_staff_info hsi  on mw.staff_info_id=hsi.staff_info_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
where
#     swm.date_at >= date_add(curdate(),interval -day(curdate())+1 day)
    mw.created_at >= date_add(curdate(), interval -day(curdate()) + 1 day)
    and mw.type_code = 'warning_27'
#     mw.created_at >= '2023-03-01'
#     and mw.created_at < '2023-04-01'
    and mw.is_delete = 0;
;-- -. . -..- - / . -. - .-. -.--
select
    'shopee' client_name
    ,pi.pno
from ph_staging.parcel_info pi
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('shopee')
left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = pi.pno
where
    pi.state not in (5,7,8,9) -- 未达终态
    and pi.returned = 0
    and ds.end_date < curdate()

union all

select
    'lazada' client_name
    ,pi.pno
from ph_staging.parcel_info pi
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada')
left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = pi.pno
where
    pi.state not in (5,7,8,9) -- 未达终态
    and pi.returned = 0
    and dl.delievey_end_date < curdate()

union all

select
    'lazada' client_name
    ,pi.pno
from ph_staging.parcel_info pi
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada')
left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = pi.pno
where
    pi.state not in (5,7,8,9) -- 未达终态
    and pi.returned = 0
    and dt.end_date < curdate();
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        'shopee' client_name
        ,pi.pno
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('shopee')
    left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and ds.end_date < curdate()

    union all

    select
        'lazada' client_name
        ,pi.pno
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada')
    left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and dl.delievey_end_date < curdate()

    union all

    select
        'lazada' client_name
        ,pi.pno
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada')
    left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and dt.end_date < curdate()

)
select
    t.pno
    ,count(pcd.id) num
from ph_staging.parcel_change_detail pcd
join t on pcd.pno = t.pno
where
    pcd.field_name = 'dst_detail_address'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        'shopee' client_name
        ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
        ,ds.end_date del_date
        ,pi.pno
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('shopee')
    left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and ds.end_date < curdate()

    union all

    select
        'lazada' client_name
        ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
        ,dl.delievey_end_date del_date
        ,pi.pno
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada')
    left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and dl.delievey_end_date < curdate()

    union all

    select
        'tiktok' client_name
        ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
        ,dt.end_date del_date
        ,pi.pno
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada')
    left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and dt.end_date < curdate()

)
select
    t.pno
    ,t.client_name 客户
    ,t.pick_time 揽收时间
    ,t.del_date 派送时效
    ,count(pcd.id) 修改收件人地址次数
from ph_staging.parcel_change_detail pcd
join t on pcd.pno = t.pno
where
    pcd.field_name = 'dst_detail_address'
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        'shopee' client_name
        ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
        ,ds.end_date del_date
        ,pi.pno
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('shopee')
    left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and ds.end_date < curdate()

    union all

    select
        'lazada' client_name
        ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
        ,dl.delievey_end_date del_date
        ,pi.pno
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada')
    left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and dl.delievey_end_date < curdate()

    union all

    select
        'tiktok' client_name
        ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
        ,dt.end_date del_date
        ,pi.pno
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada')
    left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and dt.end_date < curdate()

)
select
    t.pno
    ,t.client_name 客户
    ,t.pick_time 揽收时间
    ,t.del_date 派送时效
    ,count(pcd.id) 修改收件人地址次数
from ph_staging.parcel_change_detail pcd
join t on pcd.pno = t.pno
where
    pcd.field_name = 'dst_detail_address'
    and t.pick_time > '2023-01-01'
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        'shopee' client_name
        ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
        ,ds.end_date del_date
        ,pi.pno
        ,pi.state
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('shopee')
    left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and ds.end_date < curdate()

    union all

    select
        'lazada' client_name
        ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
        ,dl.delievey_end_date del_date
        ,pi.pno
        ,pi.state
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada')
    left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and dl.delievey_end_date < curdate()

    union all

    select
        'tiktok' client_name
        ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
        ,dt.end_date del_date
        ,pi.pno
        ,pi.state
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada')
    left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and dt.end_date < curdate()

)
select
    t.pno
    ,t.client_name 客户
    ,t.pick_time 揽收时间
    ,t.del_date 派送时效
    ,case t.state
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
    ,count(pcd.id) 修改收件人地址次数
from ph_staging.parcel_change_detail pcd
join t on pcd.pno = t.pno
where
    pcd.field_name = 'dst_detail_address'
    and t.pick_time > '2023-01-01'
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        'shopee' client_name
        ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
        ,ds.end_date del_date
        ,pi.pno
        ,pi.state
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('shopee')
    left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and ds.end_date < curdate()

    union all

    select
        'lazada' client_name
        ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
        ,dl.delievey_end_date del_date
        ,pi.pno
        ,pi.state
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada')
    left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and dl.delievey_end_date < curdate()

    union all

    select
        'tiktok' client_name
        ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
        ,dt.end_date del_date
        ,pi.pno
        ,pi.state
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada')
    left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and dt.end_date < curdate()

)
select
    t.pno
    ,t.client_name 客户
    ,t.pick_time 揽收时间
    ,t.del_date 派送时效
    ,case t.state
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
    ,count(pcd.id) 修改收件人地址次数
from ph_staging.parcel_change_detail pcd
join t on pcd.pno = t.pno
where
    pcd.field_name = 'dst_detail_address'
#     and t.pick_time > '2023-01-01'
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        'shopee' client_name
        ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
        ,ds.end_date del_date
        ,pi.pno
        ,pi.state
        ,pi.dst_store_id
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('shopee')
    left join dwm.dwd_ex_shopee_pno_period ds on ds.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and ds.end_date < curdate()

    union all

    select
        'lazada' client_name
        ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
        ,dl.delievey_end_date del_date
        ,pi.pno
        ,pi.state
        ,pi.dst_store_id
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada')
    left join dwm.dwd_ex_ph_lazada_pno_period dl on dl.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and dl.delievey_end_date < curdate()

    union all

    select
        'tiktok' client_name
        ,convert_tz(pi.created_at, '+00:00', '+08:00') pick_time
        ,dt.end_date del_date
        ,pi.pno
        ,pi.state
        ,pi.dst_store_id
    from ph_staging.parcel_info pi
    join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id and bc.client_name in ('lazada')
    left join dwm.dwd_ex_ph_tiktok_sla_detail dt on dt.pno = pi.pno
    where
        pi.state not in (5,7,8,9) -- 未达终态
        and pi.returned = 0
        and dt.end_date < curdate()

)
select
    t.pno
    ,t.client_name 客户
    ,t.pick_time 揽收时间
    ,t.del_date 派送时效
    ,case t.state
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
    ,ss.name 目的地网点
    ,count(pcd.id) 修改收件人地址次数
from ph_staging.parcel_change_detail pcd
join t on pcd.pno = t.pno
left join ph_staging.sys_store ss on ss.id = t.dst_store_id
where
    pcd.field_name = 'dst_detail_address'
#     and t.pick_time > '2023-01-01'
group by 1,2,3,4,5;
;-- -. . -..- - / . -. - .-. -.--
select
    tdm.marker_id
from ph_staging.ticket_delivery_marker tdm
        left join ph_staging.ticket_delivery td on tdm.delivery_id = td.id
where
    td.pno = 'PT61251TUYJ1AJ';
;-- -. . -..- - / . -. - .-. -.--
select
    t.pno
from t
join
    (
        select
            pr.pno
            ,pr.routed_at
            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
            ,json_extract(pr.extra_value, '$.callDuration') callDuration
        from ph_staging.parcel_route pr
        join
            (
                select t.pno from t group by 1
            ) t1 on pr.pno = t1.pno
        where
            pr.route_action in ('PHONE', 'INCOMING_CALL')
#             and pr.routed_at < date_sub(curdate(), interval 8 hour)
            and pr.routed_at >= date_sub('2023-03-01', interval 32 hour)
            and json_extract(pr.extra_value, '$.callDuration') > 0
    ) cal on cal.pno = t.pno and cal.routed_at < t.created_at and cal.date_d = t.date_d
left join
    (
        select
            td.pno
            ,tdm.created_at
            ,date(convert_tz(tdm.created_at, '+00:00', '+08:00')) date_d
        from ph_staging.ticket_delivery_marker tdm
        left join ph_staging.ticket_delivery td on tdm.delivery_id = td.id
        join
            (
                select t.pno from t group by 1
            ) t1 on td.pno = t1.pno
        where
            tdm.created_at >= date_sub('2023-03-01', interval 8 hour)
            and tdm.marker_id in (1)
    ) mak on mak.pno = t.pno and mak.date_d = t.date_d
where
    mak.created_at > cal.routed_at
    and mak.created_at < t.created_at;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        di.pno
        ,di.created_at
        ,date(convert_tz(di.created_at, '+00:00', '+08:00')) date_d
    from ph_staging.diff_info di
    where
        di.created_at >= date_sub('2023-03-01', interval 8 hour)
        and di.diff_marker_category in (31)
)
select
    t.pno
from t
join
    (
        select
            pr.pno
            ,pr.routed_at
            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
            ,json_extract(pr.extra_value, '$.callDuration') callDuration
        from ph_staging.parcel_route pr
        join
            (
                select t.pno from t group by 1
            ) t1 on pr.pno = t1.pno
        where
            pr.route_action in ('PHONE', 'INCOMING_CALL')
#             and pr.routed_at < date_sub(curdate(), interval 8 hour)
            and pr.routed_at >= date_sub('2023-03-01', interval 32 hour)
            and json_extract(pr.extra_value, '$.callDuration') > 0
    ) cal on cal.pno = t.pno and cal.routed_at < t.created_at and cal.date_d = t.date_d
left join
    (
        select
            td.pno
            ,tdm.created_at
            ,date(convert_tz(tdm.created_at, '+00:00', '+08:00')) date_d
        from ph_staging.ticket_delivery_marker tdm
        left join ph_staging.ticket_delivery td on tdm.delivery_id = td.id
        join
            (
                select t.pno from t group by 1
            ) t1 on td.pno = t1.pno
        where
            tdm.created_at >= date_sub('2023-03-01', interval 8 hour)
            and tdm.marker_id in (1)
    ) mak on mak.pno = t.pno and mak.date_d = t.date_d
where
    mak.created_at > cal.routed_at
    and mak.created_at < t.created_at;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        di.pno
        ,di.created_at
        ,date(convert_tz(di.created_at, '+00:00', '+08:00')) date_d
    from ph_staging.diff_info di
    where
        di.created_at >= date_sub('2023-03-01', interval 8 hour)
        and di.diff_marker_category in (31)
)
select
    t.*
from t
join
    (
        select
            pr.pno
            ,pr.routed_at
            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
            ,json_extract(pr.extra_value, '$.callDuration') callDuration
        from ph_staging.parcel_route pr
        join
            (
                select t.pno from t group by 1
            ) t1 on pr.pno = t1.pno
        where
            pr.route_action in ('PHONE', 'INCOMING_CALL')
#             and pr.routed_at < date_sub(curdate(), interval 8 hour)
            and pr.routed_at >= date_sub('2023-03-01', interval 32 hour)
            and json_extract(pr.extra_value, '$.callDuration') > 0
    ) cal on cal.pno = t.pno and cal.routed_at < t.created_at and cal.date_d = t.date_d
left join
    (
        select
            td.pno
            ,tdm.created_at
            ,date(convert_tz(tdm.created_at, '+00:00', '+08:00')) date_d
        from ph_staging.ticket_delivery_marker tdm
        left join ph_staging.ticket_delivery td on tdm.delivery_id = td.id
        join
            (
                select t.pno from t group by 1
            ) t1 on td.pno = t1.pno
        where
            tdm.created_at >= date_sub('2023-03-01', interval 8 hour)
            and tdm.marker_id in (1)
    ) mak on mak.pno = t.pno and mak.date_d = t.date_d
where
    mak.created_at > cal.routed_at
    and mak.created_at < t.created_at;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        di.pno
        ,di.created_at
        ,date(convert_tz(di.created_at, '+00:00', '+08:00')) date_d
    from ph_staging.diff_info di
    where
        di.created_at >= date_sub('2023-03-01', interval 8 hour)
        and di.diff_marker_category in (31)
)
select
    t.pno
    ,t.date_d 提交疑难件日期
    ,convert_tz(t.created_at, '+00:00', '+08:00') 错分疑难件交接时间
    ,convert_tz(cal.routed_at, '+00:00', '+08:00') 有通话时长通话时间
    ,cal.callDuration 通话时长
    ,convert_tz(mak.created_at, '+00:00', '+08:00') 标记联系不上时间
from t
join
    (
        select
            pr.pno
            ,pr.routed_at
            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) date_d
            ,json_extract(pr.extra_value, '$.callDuration') callDuration
        from ph_staging.parcel_route pr
        join
            (
                select t.pno from t group by 1
            ) t1 on pr.pno = t1.pno
        where
            pr.route_action in ('PHONE', 'INCOMING_CALL')
#             and pr.routed_at < date_sub(curdate(), interval 8 hour)
            and pr.routed_at >= date_sub('2023-03-01', interval 32 hour)
            and json_extract(pr.extra_value, '$.callDuration') > 0
    ) cal on cal.pno = t.pno and cal.routed_at < t.created_at and cal.date_d = t.date_d
left join
    (
        select
            td.pno
            ,tdm.created_at
            ,date(convert_tz(tdm.created_at, '+00:00', '+08:00')) date_d
        from ph_staging.ticket_delivery_marker tdm
        left join ph_staging.ticket_delivery td on tdm.delivery_id = td.id
        join
            (
                select t.pno from t group by 1
            ) t1 on td.pno = t1.pno
        where
            tdm.created_at >= date_sub('2023-03-01', interval 8 hour)
            and tdm.marker_id in (1)
    ) mak on mak.pno = t.pno and mak.date_d = t.date_d
where
    mak.created_at > cal.routed_at
    and mak.created_at < t.created_at;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno 输入单号
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 物品价值
    ,pi2.cod_amount/100 COD金额
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_0417 t on pi.pno = t.pno
left join ph_staging.parcel_info pi2 on if(pi.returned = 0, pi.pno, pi.customary_pno) = pi2.pno
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_staging.ka_profile kp on kp.id = pi2.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi2.client_id

union

select
    t.pno 输入单号
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 物品价值
    ,pi2.cod_amount/100 COD金额
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_0417 t on pi.recent_pno = t.pno
left join ph_staging.parcel_info pi2 on if(pi.returned = 0, pi.pno, pi.customary_pno) = pi2.pno
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_staging.ka_profile kp on kp.id = pi2.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi2.client_id

union

select
    t.pno 输入单号
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 物品价值
    ,pi2.cod_amount/100 COD金额
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_0417 t on pi.pno = t.pno
left join ph_staging.parcel_info pi2 on if(pi.returned = 0, pi.pno, pi.customary_pno) = pi2.pno
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_staging.ka_profile kp on kp.id = pi2.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi2.client_id;
;-- -. . -..- - / . -. - .-. -.--
select
    de.pno
    ,if(bc.client_name is not null , bc.client_name, 'ka&c') client_name
    ,datediff(curdate(), de.dst_routed_at) days
from dwm.dwd_ex_ph_parcel_details de
left join dwm.dwd_dim_bigClient bc on bc.client_id = de.client_id
where
    de.parcel_state not in (5,7,8,9)
    and de.dst_routed_at is not null;
;-- -. . -..- - / . -. - .-. -.--
select
    t1.dst_store
    ,count(t1.pno) 在仓包裹数
    ,count(if(t1.cod_enabled = 1, t1.pno, null)) 在仓COD包裹数
    ,count(if(t1.days <= 3, t1.pno, null)) 3日内滞留
    ,count(if(t1.days <= 3 and t1.cod_enabled = 1, t1.pno, null)) 3日内COD滞留
    ,count(if(t1.days <= 5, t1.pno, null)) 5日内滞留
    ,count(if(t1.days <= 5 and t1.cod_enabled = 1, t1.pno, null)) 5日内COD滞留
    ,count(if(t1.days <= 7, t1.pno, null)) 7日内滞留
    ,count(if(t1.days <= 7 and t1.cod_enabled = 1, t1.pno, null)) 7日内COD滞留
    ,count(if(t1.client_name = 'lazada', t1.pno, null)) lazada在仓
    ,count(if(t1.client_name = 'lazada' and t1.cod_enabled = 1, t1.pno, null)) lazadaCOD在仓
    ,count(if(t1.client_name = 'shopee', t1.pno, null)) shopee在仓
    ,count(if(t1.client_name = 'shopee' and t1.cod_enabled = 1, t1.pno, null)) shopeeCOD在仓
    ,count(if(t1.client_name = 'tiktok', t1.pno, null)) tt在仓
    ,count(if(t1.client_name = 'tiktok' and t1.cod_enabled = 1, t1.pno, null)) ttCOD在仓
    ,count(if(t1.client_name = 'ka&c', t1.pno, null)) 'KA&小C在仓'
    ,count(if(t1.client_name = 'ka&c' and t1.cod_enabled = 1, t1.pno, null)) 'KA&小CCOD在仓'
from
    (
        select
            de.pno
            ,de.dst_store_id
            ,de.dst_store
            ,if(bc.client_name is not null , bc.client_name, 'ka&c') client_name
            ,datediff(curdate(), de.dst_routed_at) days
            ,de.cod_enabled
        from dwm.dwd_ex_ph_parcel_details de
        left join dwm.dwd_dim_bigClient bc on bc.client_id = de.client_id
        where
            de.parcel_state not in (5,7,8,9)
            and de.dst_routed_at is not null
    ) t1
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,case
        when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
        when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
        when hsi.`state`=2 then '离职'
        when hsi.`state`=3 then '停职'
        end as 在职状态
        ,ss.name 所属网点
        ,smr.name  大区
        ,smp.name  片区
        ,convert_tz(mw.created_at,'+00:00','+08:00') created_at
        ,case mw.type_code
            when 'warning_1'  then '迟到早退'
            when 'warning_29' then '贪污包裹'
            when 'warning_30' then '偷盗公司财物'
            when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
            when 'warning_9'  then '腐败/滥用职权'
            when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_08'  then '公司设备私人使用 / 利用公司设备去做其他事情'
            when 'warning_5'  then '持有或吸食毒品'
            when 'warning_4'  then '工作时间或工作地点饮酒'
            when 'warning_10' then '玩忽职守'
            when 'warning_2'  then '无故连续旷工3天'
            when 'warning_3'  then '贪污'
            when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
            when 'warning_7'  then '通过社会媒体污蔑公司'
            when 'warning_27' then '工作效率未达到公司的标准(KPI)'
            when 'warning_26' then 'Fake POD'
            when 'warning_25' then 'Fake Status'
            when 'warning_24' then '不接受或不配合公司的调查'
            when 'warning_23' then '损害公司名誉'
            when 'warning_22' then '失职'
            when 'warning_28' then '贪污钱'
            when 'warning_21' then '煽动/挑衅/损害公司利益'
            when 'warning_20' then '谎报里程'
            when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
            when 'warning_19' then '未按照网点规定的时间回款'
            when 'warning_17' then '伪造证件'
            when 'warning_12' then '未告知上级或无故旷工'
            when 'warning_13' then '上级没有同意请假'
            when 'warning_14' then '没有通过系统请假'
            when 'warning_15' then '未按时上下班'
            when 'warning_16' then '不配合公司的吸毒检查'
            when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
            else mw.`type_code`
        end as '警告原因'
        ,case mw.`warning_type`
        when 1 then '口述警告'
        when 2 then '书面警告'
        when 3 then '末次书面警告'
        end as 警告类型
        ,ROW_NUMBER ()over(partition by hsi.staff_info_id order by mw.created_at ) rn
        ,count(mw.id) over (partition by hsi.staff_info_id) ct
    from
    (
             select
                mw.staff_info_id
            from ph_backyard.message_warning mw
            where
                mw.type_code = 'warning_27'
                and mw.operator_id = 87166
                and mw.is_delete = 0
#             and mw.created_at >=convert_tz('2023-04-13','+08:00','+00:00')
            group by 1
    )ws
    join ph_bi.hr_staff_info hsi  on ws.staff_info_id=hsi.staff_info_id
    left join  ph_backyard.message_warning mw on hsi.staff_info_id =mw.staff_info_id and  mw.is_delete =0
    left join ph_staging.sys_store ss on hsi.sys_store_id =ss.id
    left join ph_staging.sys_manage_region smr on ss.manage_region =smr.id
    left join ph_staging.sys_manage_piece smp on ss.manage_piece =smp.id
    where
        hsi.state <> 2
)

select 
    t.staff_info_id 员工id
    ,t. 在职状态
    ,t.所属网点
    ,t.大区
    ,t.片区
    ,t.ct 警告次数
    ,t.created_at 第一次警告信时间
    ,t.警告原因 第一次警告原因
    ,t.警告类型 第一次警告类型
    ,t2.created_at 第二次警告信时间
    ,t2.警告原因 第二次警告原因
    ,t2.警告类型 第二次警告类型
    ,t3.created_at 第三次警告信时间
    ,t3.警告原因 第三次警告原因
    ,t3.警告类型 第三次警告类型
    ,t4.created_at 第四次警告信时间
    ,t4.警告原因 第四次警告原因
    ,t4.警告类型 第四次警告类型
    ,t5.created_at 第五次警告信时间
    ,t5.警告原因 第五次警告原因
    ,t5.警告类型 第五次警告类型
from t 
left join t t2 on t.staff_info_id=t2.staff_info_id and t2.rn=2
left join t t3 on t.staff_info_id=t3.staff_info_id and t3.rn=3
left join t t4 on t.staff_info_id=t4.staff_info_id and t4.rn=4
left join t t5 on t.staff_info_id=t5.staff_info_id and t5.rn=5
where
    t.rn=1;
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno 输入单号
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 物品价值
    ,pi2.cod_amount/100 COD金额
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on if(pi.returned = 0, pi.pno, pi.customary_pno) = pi2.pno
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_staging.ka_profile kp on kp.id = pi2.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi2.client_id
where
    pi.recent_pno in ('P35511D0J3BAG');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.pno 输入单号
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 物品价值
    ,pi2.cod_amount/100 COD金额
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on if(pi.returned = 0, pi.pno, pi.customary_pno) = pi2.pno
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_staging.ka_profile kp on kp.id = pi2.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi2.client_id
where
    pi.pno in ('P35511D0J3BAG');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.cod_amount
    ,pi.insure_declare_value
from ph_staging.parcel_info pi
where
    pi.pno = 'P35511D0J3BAG';
;-- -. . -..- - / . -. - .-. -.--
select
    oi.cod_amount
    ,oi.insure_declare_value
    ,oi.cogs_amount
from ph_staging.order_info oi
where
    oi.pno = 'P35511D0J3BAG';
;-- -. . -..- - / . -. - .-. -.--
select
    oi.cod_amount
    ,oi.insure_declare_value
    ,oi.cogs_amount
    ,oi.cod_enabled
from ph_staging.order_info oi
where
    oi.pno = 'P35511D0J3BAG';
;-- -. . -..- - / . -. - .-. -.--
select
    oi.cod_amount
    ,oi.insure_declare_value
#     ,oi.cogs_amount
    ,oi.cod_enabled
from ph_staging.parcel_info  oi
where
    oi.pno = 'P35511D0J3BAG';
;-- -. . -..- - / . -. - .-. -.--
select
    ppl.replace_pno 输入单号
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,loi.item_name 产品名称
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 物品价值
    ,pi2.cod_amount/100 COD金额
from ph_staging.parcel_pno_log ppl
left join ph_staging.parcel_info pi on pi.pno = ppl.initial_pno
left join ph_staging.parcel_info pi2 on if(pi.returned = 0, pi.pno, pi.customary_pno) = pi2.pno
left join ph_drds.lazada_order_info_d loi on loi.pno = pi2.pno
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_staging.ka_profile kp on kp.id = pi2.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi2.client_id
where
    ppl.replace_pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')

union all

select
    pi.pno 输入单号
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,loi.item_name 产品名称
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 物品价值
    ,pi2.cod_amount/100 COD金额
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on if(pi.returned = 0, pi.pno, pi.customary_pno) = pi2.pno
left join ph_drds.lazada_order_info_d loi on loi.pno = pi2.pno
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_staging.ka_profile kp on kp.id = pi2.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi2.client_id
where
    pi.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}');
;-- -. . -..- - / . -. - .-. -.--
select  date_sub(curdate(), interval 3 day);
;-- -. . -..- - / . -. - .-. -.--
select
            de.dst_store_id
            ,de.dst_store
            ,count(if(de.parcel_state = 5 and datediff(de.finished_date, de.dst_routed_at) > 7 , de.pno, null)) over_7day_num
            ,count(if(de.parcel_state = 5 and datediff(de.finished_date, de.dst_routed_at) > 7 , de.pno, null))/count(de.pno) over_7day_rate
        from dwm.dwd_ex_ph_parcel_details de
        where
            de.cod_enabled = 1
            and de.parcel_state < 9
            and
                (
                    ( de.parcel_state not in (5,7,8,9) and de.dst_routed_at < date_sub(date_sub(curdate(), interval 7 day), interval 8 hour))
                    or ( de.parcel_state in (5,7,8) and de.updated_at > date_sub(date_sub(curdate(), interval 7 day) and de.dst_routed_at < date_sub(date_sub(curdate(), interval 7 day), interval 8 hour), interval 8 hour)  )
                )
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
            de.dst_store_id
            ,de.dst_store
            ,count(if(de.parcel_state = 5 and datediff(de.finished_date, de.dst_routed_at) > 7 , de.pno, null)) over_7day_num
            ,count(if(de.parcel_state = 5 and datediff(de.finished_date, de.dst_routed_at) > 7 , de.pno, null))/count(de.pno) over_7day_rate
        from dwm.dwd_ex_ph_parcel_details de
        where
            de.cod_enabled = 1
            and de.parcel_state < 9;
;-- -. . -..- - / . -. - .-. -.--
select
            de.dst_store_id
            ,de.dst_store
            ,count(if(de.parcel_state = 5 and datediff(de.finished_date, de.dst_routed_at) > 7 , de.pno, null)) over_7day_num
            ,count(if(de.parcel_state = 5 and datediff(de.finished_date, de.dst_routed_at) > 7 , de.pno, null))/count(de.pno) over_7day_rate
        from dwm.dwd_ex_ph_parcel_details de
        where
            de.cod_enabled = 1
            and de.parcel_state < 9
            and
                (
                    ( de.parcel_state not in (5,7,8,9) and de.dst_routed_at < date_sub(date_sub(curdate(), interval 7 day), interval 8 hour))
                    or ( de.parcel_state in (5,7,8) and de.updated_at > date_sub(date_sub(curdate(), interval 7 day), interval 8 hour) and de.dst_routed_at < date_sub(date_sub(curdate(), interval 7 day), interval 8 hour))
                )
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
            de.dst_store_id
            ,de.dst_store
            ,count(de.pno) sh_num
            ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null)) last_5_7day_num
            ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null))/count(de.pno) last_5_7day_rate
        from dwm.dwd_ex_ph_parcel_details de
        where
            de.cod_enabled = 1
            and de.dst_routed_at >= date_sub(date_sub(curdate(), interval 7 day), interval 8 hour) -- 3天前到达
            and de.dst_routed_at < date_add(date_sub(curdate(), interval 7 day), interval 16 hour) -- 3天前到达
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
            de.dst_store_id
            ,de.dst_store
            ,count(if(de.parcel_state = 5 and datediff(de.finished_date, de.dst_routed_at) > 7 , de.pno, null)) over_7day_num
            ,count(if(de.parcel_state = 5 and datediff(de.finished_date, de.dst_routed_at) > 7 , de.pno, null))/count(de.pno) over_7day_rate
        from dwm.dwd_ex_ph_parcel_details de
        where
            de.cod_enabled = 'YES'
            and de.parcel_state < 9
            and
                (
                    ( de.parcel_state not in (5,7,8,9) and de.dst_routed_at < date_sub(date_sub(curdate(), interval 7 day), interval 8 hour))
                    or ( de.parcel_state in (5,7,8) and de.updated_at > date_sub(date_sub(curdate(), interval 7 day), interval 8 hour) and de.dst_routed_at < date_sub(date_sub(curdate(), interval 7 day), interval 8 hour))
                )
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    de.dst_store_id
    ,de.dst_store
    ,count(t.pno) shre_num
    ,count(if(de.cod_enabled = 'YES', de.pno, null)) cod_shre_num
    ,count(if(de.return_time is not null, de.pno, null)) realre_num
    ,count(if(de.return_time is not null and de.cod_enabled = 'YES', de.pno, null)) cod_ralre_num
    ,count(if(de.return_time is not null, de.pno, null))/count(t.pno) re_rate
    ,count(if(de.return_time is not null and de.cod_enabled = 'YES', de.pno, null))/count(if(de.cod_enabled = 'YES', de.pno, null)) cod_re_rate
from
    (
        select
            pr.pno
            ,pr.store_id
        from ph_staging.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 8 hour)
            and pr.route_action = 'PENDING_RETURN' -- 待退件
        group by 1,2
    ) t
join dwm.dwd_ex_ph_parcel_details de on t.pno = de.pno and t.store_id = de.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    de.dst_store_id
    ,de.dst_store
    ,count(t.pno) shre_num
    ,count(if(de.cod_enabled = 'YES', de.pno, null)) cod_shre_num
    ,count(if(de.return_time is not null, de.pno, null)) realre_num
    ,count(if(de.return_time is not null and de.cod_enabled = 'YES', de.pno, null)) cod_ralre_num
    ,count(if(de.return_time is not null, de.pno, null))/count(t.pno) re_rate
    ,count(if(de.return_time is not null and de.cod_enabled = 'YES', de.pno, null))/count(if(de.cod_enabled = 'YES', de.pno, null)) cod_re_rate
from
    (
        select
            pr.pno
            ,pr.store_id
        from ph_staging.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 8 hour)
            and pr.route_action = 'PENDING_RETURN' -- 待退件
        group by 1,2
    ) t
join dwm.dwd_ex_ph_parcel_details de on t.pno = de.pno and t.store_id = de.dst_store_id
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
            pr.pno
            ,pr.store_id
        from ph_staging.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 8 hour)
            and pr.route_action = 'PENDING_RETURN' -- 待退件
        group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    de.dst_store_id
    ,de.dst_store
    ,count(t.pno) shre_num
    ,count(if(de.cod_enabled = 'YES', de.pno, null)) cod_shre_num
    ,count(if(de.return_time is not null, de.pno, null)) realre_num
    ,count(if(de.return_time is not null and de.cod_enabled = 'YES', de.pno, null)) cod_ralre_num
    ,count(if(de.return_time is not null, de.pno, null))/count(t.pno) re_rate
    ,count(if(de.return_time is not null and de.cod_enabled = 'YES', de.pno, null))/count(if(de.cod_enabled = 'YES', de.pno, null)) cod_re_rate
from
    (
        select
            pr.pno
        from ph_staging.parcel_route pr
        where
            pr.routed_at > date_sub(curdate(), interval 8 hour)
            and pr.route_action = 'PENDING_RETURN' -- 待退件
        group by 1
    ) t
join dwm.dwd_ex_ph_parcel_details de on t.pno = de.pno
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with s1 as
(
    select
        t1.dst_store_id store_id
        ,t1.dst_store store_name
        ,count(t1.pno) 在仓包裹数
        ,count(if(t1.cod_enabled = 'YES', t1.pno, null)) 在仓COD包裹数
        ,count(if(t1.days <= 3, t1.pno, null)) 3日内滞留
        ,count(if(t1.days <= 3 and t1.cod_enabled = 'YES', t1.pno, null)) 3日内COD滞留
        ,count(if(t1.days <= 5, t1.pno, null)) 5日内滞留
        ,count(if(t1.days <= 5 and t1.cod_enabled = 'YES', t1.pno, null)) 5日内COD滞留
        ,count(if(t1.days <= 7, t1.pno, null)) 7日内滞留
        ,count(if(t1.days <= 7 and t1.cod_enabled = 'YES', t1.pno, null)) 7日内COD滞留
        ,count(if(t1.days > 7, t1.pno, null)) 超7天滞留
        ,count(if(t1.days > 7 and t1.cod_enabled = 'YES', t1.pno, null)) 超7天COD滞留
        ,count(if(t1.client_name = 'lazada', t1.pno, null)) lazada在仓
        ,count(if(t1.client_name = 'lazada' and t1.cod_enabled = 'YES', t1.pno, null)) lazadaCOD在仓
        ,count(if(t1.client_name = 'shopee', t1.pno, null)) shopee在仓
        ,count(if(t1.client_name = 'shopee' and t1.cod_enabled = 'YES', t1.pno, null)) shopeeCOD在仓
        ,count(if(t1.client_name = 'tiktok', t1.pno, null)) tt在仓
        ,count(if(t1.client_name = 'tiktok' and t1.cod_enabled = 'YES', t1.pno, null)) ttCOD在仓
        ,count(if(t1.client_name = 'ka&c', t1.pno, null)) 'KA&小C在仓'
        ,count(if(t1.client_name = 'ka&c' and t1.cod_enabled = 'YES', t1.pno, null)) 'KA&小CCOD在仓'
    from
        (
            select
                de.pno
                ,de.dst_store_id
                ,de.dst_store
                ,if(bc.client_name is not null , bc.client_name, 'ka&c') client_name
                ,datediff(curdate(), de.dst_routed_at) days
                ,de.cod_enabled
            from dwm.dwd_ex_ph_parcel_details de
            left join dwm.dwd_dim_bigClient bc on bc.client_id = de.client_id
            where
                de.parcel_state not in (5,7,8,9)
                and de.dst_routed_at is not null
        ) t1
    group by 1
)
,s2 as
(
    select
        a1.dst_store_id store_id
        ,a1.dst_store store_name
        ,a1.num 当日到达COD包裹
        ,a2.num 当日交接COD包裹
        ,a3.num 当日妥投COD包裹
        ,a3.num/a1.num 当日到站COD妥投率
        ,a4.last_3day_num 3日内COD妥投包裹
        ,a4.last_3day_rate 3日COD妥投率
        ,a5.last_3_5day_num 5日COD妥投包裹
        ,a5.last_3_5day_rate 5日COD妥投率
        ,a6.last_5_7day_num 7日内COD包裹妥投数
        ,a6.last_5_7day_rate 7日COD妥投率
        ,a7.over_7day_num 超7日COD包裹妥投数
        ,a7.over_7day_rate 超7日COD妥投率
    from
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) num
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.dst_routed_at >= date_sub(curdate(), interval 8 hour )
                and de.dst_routed_at < date_add(curdate(), interval 16 hour)
                and de.cod_enabled = 'YES'
            group by 1,2
        ) a1
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) num
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.dst_routed_at >= date_sub(curdate(), interval 8 hour )
                and de.dst_routed_at < date_add(curdate(), interval 16 hour)
                and de.first_scan_time >= date_sub(curdate(), interval 8 hour )
                and de.first_scan_time < date_add(curdate(), interval 16 hour)
                and de.cod_enabled = 'YES'
            group by 1,2
        ) a2  on a2.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) num
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.dst_routed_at >= date_sub(curdate(), interval 8 hour )
                and de.dst_routed_at < date_add(curdate(), interval 16 hour)
                and de.finished_date = curdate()
                and de.parcel_state = 5
                and de.cod_enabled = 'YES'
            group by 1,2
        ) a3 on a3.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) sh_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null)) last_3day_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null))/count(de.pno) last_3day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.dst_routed_at >= date_sub(date_sub(curdate(), interval 3 day), interval 8 hour) -- 3天前到达
                and de.dst_routed_at < date_add(date_sub(curdate(), interval 3 day), interval 16 hour) -- 3天前到达
            group by 1,2
         ) a4 on a4.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) sh_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null)) last_3_5day_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null))/count(de.pno) last_3_5day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.dst_routed_at >= date_sub(date_sub(curdate(), interval 5 day), interval 8 hour) -- 3天前到达
                and de.dst_routed_at < date_add(date_sub(curdate(), interval 5 day), interval 16 hour) -- 3天前到达
            group by 1,2
        ) a5 on a5.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) sh_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null)) last_5_7day_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null))/count(de.pno) last_5_7day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.dst_routed_at >= date_sub(date_sub(curdate(), interval 7 day), interval 8 hour) -- 3天前到达
                and de.dst_routed_at < date_add(date_sub(curdate(), interval 7 day), interval 16 hour) -- 3天前到达
            group by 1,2
        ) a6 on a6.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(if(de.parcel_state = 5 and datediff(de.finished_date, de.dst_routed_at) > 7 , de.pno, null)) over_7day_num
                ,count(if(de.parcel_state = 5 and datediff(de.finished_date, de.dst_routed_at) > 7 , de.pno, null))/count(de.pno) over_7day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.parcel_state < 9
                and
                    (
                        ( de.parcel_state not in (5,7,8,9) and de.dst_routed_at < date_sub(date_sub(curdate(), interval 7 day), interval 8 hour))
                        or ( de.parcel_state in (5,7,8) and de.updated_at > date_sub(date_sub(curdate(), interval 7 day), interval 8 hour) and de.dst_routed_at < date_sub(date_sub(curdate(), interval 7 day), interval 8 hour))
                    )
            group by 1,2
        ) a7 on a7.dst_store_id = a1.dst_store_id
)
,s3 as
-- 应退件
(
    select
        de.dst_store_id store_id
        ,de.dst_store  store_name
        ,count(t.pno)  应退件包裹
        ,count(if(de.cod_enabled = 'YES', de.pno, null)) 应退件COD包裹
        ,count(if(de.return_time is not null, de.pno, null)) 实际退件包裹
        ,count(if(de.return_time is not null and de.cod_enabled = 'YES', de.pno, null)) 实际退件COD包裹
        ,count(if(de.return_time is not null, de.pno, null))/count(t.pno) 退件操作完成率
        ,count(if(de.return_time is not null and de.cod_enabled = 'YES', de.pno, null))/count(if(de.cod_enabled = 'YES', de.pno, null)) COD退件操作完成率
    from
        (
            select
                pr.pno
            from ph_staging.parcel_route pr
            where
                pr.routed_at > date_sub(curdate(), interval 8 hour)
                and pr.route_action = 'PENDING_RETURN' -- 待退件
            group by 1
        ) t
    join dwm.dwd_ex_ph_parcel_details de on t.pno = de.pno
    group by 1,2
)
,s4 as
(
    select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5, pss.pno and pi2.cod_enabled = 1, null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5, pss.pno and pi2.cod_enabled = 1, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pss.pno and pr.store_id = pss.next_store_id and pr.routed_at > date_sub(curdate(), interval 8 hour) and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at > curdate()
    group by 1,2
)
select
    ss.store_id
    ,ss.store_name
    ,s1.在仓包裹数, s1.在仓COD包裹数, s1.`3日内滞留`, s1.`3日内COD滞留`, s1.`5日内滞留`, s1.`5日内COD滞留`, s1.`7日内滞留`, s1.`7日内COD滞留`, s1.超7天滞留, s1.超7天COD滞留, s1.lazada在仓, s1.lazadaCOD在仓, s1.shopee在仓, s1.shopeeCOD在仓, s1.tt在仓, s1.ttCOD在仓, s1.`KA&小C在仓`, s1.`KA&小CCOD在仓`
    ,s2.当日到达COD包裹, s2.当日交接COD包裹, s2.当日妥投COD包裹, s2.当日到站COD妥投率, s2.`3日内COD妥投包裹`, s2.`3日COD妥投率`, s2.`5日COD妥投包裹`, s2.`5日COD妥投率`, s2.`7日内COD包裹妥投数`, s2.`7日COD妥投率`, s2.超7日COD包裹妥投数, s2.超7日COD妥投率
    ,s3.应退件包裹, s3.应退件COD包裹, s3.实际退件包裹, s3.实际退件COD包裹, s3.退件操作完成率, s3.COD退件操作完成率
    ,s4.应到退件包裹, s4.应到退件COD包裹, s4.实到退件包裹, s4.实到退件COD包裹, s4.退件妥投包裹, s4.退件妥投COD包裹, s4.退件妥投完成率, s4.COD退件妥投完成率
from
    (
        select s1.store_id,s1.store_name from s1 group by 1,2
        union all
        select s2.store_id,s2.store_name from s2 group by 1,2
        union all
        select s3.store_id,s3.store_name from s3 group by 1,2
        union all
        select s4.store_id,s4.store_name from s4 group by 1,2
    ) ss
left join s1 on s1.store_id = ss.store_id
left join s2 on s2.store_id = ss.store_id
left join s3 on s3.store_id = ss.store_id
left join s4 on s4.store_id = ss.store_id;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5, pss.pno and pi2.cod_enabled = 1, null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5, pss.pno and pi2.cod_enabled = 1, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
#     left join ph_staging.parcel_route pr on pr.pno = pss.pno and pr.store_id = pss.next_store_id and pr.routed_at > date_sub(curdate(), interval 8 hour) and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at > curdate()
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5, pss.pno and pi2.cod_enabled = 1, null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5, pss.pno and pi2.cod_enabled = 1, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pss.pno and pr.store_id = pss.next_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at > curdate()
        and pr.routed_at > date_sub(curdate(), interval 8 hour)
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pss.pno and pr.store_id = pss.next_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at > curdate()
        and pr.routed_at > date_sub(curdate(), interval 8 hour)
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pss.pno and pr.store_id = pss.next_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN' and pr.routed_at > date_sub(curdate(), interval 8 hour)
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at > curdate()

    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
#         ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
#         ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
#         ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
#         ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
#     left join ph_staging.parcel_route pr on pr.pno = pss.pno and pr.store_id = pss.next_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN' and pr.routed_at > date_sub(curdate(), interval 8 hour)
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at > curdate()

    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pss.pno and pr.store_id = pss.next_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN' and pr.routed_at > date_sub(curdate(), interval 8 hour)
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at > curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pss.pno and pr.store_id = pss.next_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN' and pr.routed_at > date_sub(curdate(), interval 8 hour)
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
#         and pss.van_plan_arrived_at > curdate()
#         and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pss.pno and pr.store_id = pss.next_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN' and pr.routed_at > date_sub(curdate(), interval 8 hour)
    where
        pi.returned = 1
#         and pss.next_store_id = pi.dst_store_id
#         and pss.van_left_at is not null
        and pss.van_plan_arrived_at > curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
#         ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
#         ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pss.pno and pr.store_id = pss.next_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN' and pr.routed_at > date_sub(curdate(), interval 8 hour)
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at > curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
#         ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
#         ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
#         ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
#         ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pss.pno and pr.store_id = pss.next_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN' and pr.routed_at > date_sub(curdate(), interval 8 hour)
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at > curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join
        (
            select
                pr.pno
                ,pr.store_id
            from ph_staging.parcel_route pr
            join
                (
                    select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1
                ) a
            where
                pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                and pr.routed_at > date_sub(curdate(), interval 8 hour)
        ) pr on pr.pno = pi.pno and pr.store_id = pss.next_store_id
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at >= curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join
        (
            select
                pr.pno
                ,pr.store_id
            from ph_staging.parcel_route pr
            join
                (
                    select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1
                ) a on pr.pno = a.pno
            where
                pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                and pr.routed_at > date_sub(curdate(), interval 8 hour)
        ) pr on pr.pno = pi.pno and pr.store_id = pss.next_store_id
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at >= curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join
        (
            select
                pr.pno
                ,pr.store_id
            from ph_staging.parcel_route pr
            join
                (
                    select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1
                ) a on pr.pno = a.pno
            where
                pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                and pr.routed_at > date_sub(curdate(), interval 8 hour)
        ) pr on pr.pno = pi.pno and pr.store_id = pi.dst_store_id
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at >= curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1
                ) a on pr.pno = a.pno
            where
                pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                and pr.routed_at > date_sub(curdate(), interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
select
                pi.state
                ,pss.pno
                ,pi2.cod_enabled
                ,pss.next_store_id
                ,pss.next_store_name
            from dw_dmd.parcel_store_stage_new pss
            join ph_staging.parcel_info pi on pss.pno = pi.pno
            left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
            where
                pi.returned = 1
                and pss.next_store_id = pi.dst_store_id
                and pss.van_left_at is not null
                and pss.van_plan_arrived_at >= curdate()
                and pss.next_store_id is not null;
;-- -. . -..- - / . -. - .-. -.--
select
        a.next_store_id store_id
        ,a.next_store_name store_name
        ,count(distinct a.pno) 应到退件包裹
        ,count(distinct (a.cod_enabled = 1, a.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , a.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and a.cod_enabled = 1, a.pno, null)) 实到退件COD包裹
        ,count(distinct if(a.state = 5, a.pno, null)) 退件妥投包裹
        ,count(distinct if(a.state = 5 and a.cod_enabled = 1, a.pno , null)) 退件妥投COD包裹
        ,count(distinct if(a.state = 5, a.pno, null))/count(distinct if(pr.pno is not null , a.pno, null)) 退件妥投完成率
        ,count(distinct if(a.state = 5 and a.cod_enabled = 1, a.pno, null))/count(distinct if(pr.pno is not null and a.cod_enabled = 1, a.pno, null)) COD退件妥投完成率
    from
        (
            select
                pi.state
                ,pss.pno
                ,pi2.cod_enabled
                ,pss.next_store_id
                ,pss.next_store_name
            from dw_dmd.parcel_store_stage_new pss
            join ph_staging.parcel_info pi on pss.pno = pi.pno
            left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
            where
                pi.returned = 1
                and pss.next_store_id = pi.dst_store_id
                and pss.van_left_at is not null
                and pss.van_plan_arrived_at >= curdate()
                and pss.next_store_id is not null
        ) a
    left join
        (
            select
                pr.pno
                ,pr.store_id
            from ph_staging.parcel_route pr
            join
                (
                    select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1
                ) a on pr.pno = a.pno
            where
                pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                and pr.routed_at > date_sub(curdate(), interval 8 hour)
        ) pr on pr.pno = a.pno and pr.store_id = a.next_store_id
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        a.next_store_id store_id
        ,a.next_store_name store_name
        ,count(distinct a.pno) 应到退件包裹
        ,count(distinct (a.cod_enabled = 1, a.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , a.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and a.cod_enabled = 1, a.pno, null)) 实到退件COD包裹
        ,count(distinct if(a.state = 5, a.pno, null)) 退件妥投包裹
        ,count(distinct if(a.state = 5 and a.cod_enabled = 1, a.pno , null)) 退件妥投COD包裹
        ,count(distinct if(a.state = 5, a.pno, null))/count(distinct if(pr.pno is not null , a.pno, null)) 退件妥投完成率
        ,count(distinct if(a.state = 5 and a.cod_enabled = 1, a.pno, null))/count(distinct if(pr.pno is not null and a.cod_enabled = 1, a.pno, null)) COD退件妥投完成率
    from
        (
            select
                pi.state
                ,pss.pno
                ,pi2.cod_enabled
                ,pss.next_store_id
                ,pss.next_store_name
            from dw_dmd.parcel_store_stage_new pss
            join ph_staging.parcel_info pi on pss.pno = pi.pno
            left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
            where
                pi.returned = 1
                and pss.next_store_id = pi.dst_store_id
                and pss.van_left_at is not null
                and pss.van_plan_arrived_at >= curdate()
                and pss.next_store_id is not null
        ) a
    left join
        (
            select
                pr.pno
                ,pr.store_id
            from ph_staging.parcel_route pr
            join
                (
                    select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1
                ) a on pr.pno = a.pno
            where
                pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                and pr.routed_at > date_sub(curdate(), interval 8 hour)
        ) pr on pr.pno = a.pno and pr.store_id = coalesce(a.next_store_id, 0)
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
                pr.pno
                ,pr.store_id
            from ph_staging.parcel_route pr
            join
                (
                    select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1
                ) a on pr.pno = a.pno
            where
                pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                and pr.routed_at > date_sub(curdate(), interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
select
        a.next_store_id store_id
        ,a.next_store_name store_name
        ,count(distinct a.pno) 应到退件包裹
        ,count(distinct (a.cod_enabled = 1, a.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , a.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and a.cod_enabled = 1, a.pno, null)) 实到退件COD包裹
        ,count(distinct if(a.state = 5, a.pno, null)) 退件妥投包裹
        ,count(distinct if(a.state = 5 and a.cod_enabled = 1, a.pno , null)) 退件妥投COD包裹
        ,count(distinct if(a.state = 5, a.pno, null))/count(distinct if(pr.pno is not null , a.pno, null)) 退件妥投完成率
        ,count(distinct if(a.state = 5 and a.cod_enabled = 1, a.pno, null))/count(distinct if(pr.pno is not null and a.cod_enabled = 1, a.pno, null)) COD退件妥投完成率
    from
        (
            select
                pi.state
                ,pss.pno
                ,pi2.cod_enabled
                ,pss.next_store_id
                ,pss.next_store_name
            from dw_dmd.parcel_store_stage_new pss
            join ph_staging.parcel_info pi on pss.pno = pi.pno
            left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
            where
                pi.returned = 1
                and pss.next_store_id = pi.dst_store_id
                and pss.van_left_at is not null
                and pss.van_plan_arrived_at >= curdate()
                and pss.next_store_id is not null
        ) a
    left join
        (
            select
                pr.pno
                ,pr.store_id
            from ph_staging.parcel_route pr
            join
                (
                    select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1
                ) a on pr.pno = a.pno
            where
                pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                and pr.routed_at > date_sub(curdate(), interval 8 hour)
        ) pr on pr.pno = a.pno and coalesce(a.next_store_id, 1) = coalesce(a.next_store_id, 0)
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        a.next_store_id store_id
        ,a.next_store_name store_name
        ,count(distinct a.pno) 应到退件包裹
        ,count(distinct (a.cod_enabled = 1, a.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , a.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and a.cod_enabled = 1, a.pno, null)) 实到退件COD包裹
        ,count(distinct if(a.state = 5, a.pno, null)) 退件妥投包裹
        ,count(distinct if(a.state = 5 and a.cod_enabled = 1, a.pno , null)) 退件妥投COD包裹
        ,count(distinct if(a.state = 5, a.pno, null))/count(distinct if(pr.pno is not null , a.pno, null)) 退件妥投完成率
        ,count(distinct if(a.state = 5 and a.cod_enabled = 1, a.pno, null))/count(distinct if(pr.pno is not null and a.cod_enabled = 1, a.pno, null)) COD退件妥投完成率
    from
        (
            select
                pi.state
                ,pss.pno
                ,pi2.cod_enabled
                ,pss.next_store_id
                ,pss.next_store_name
            from dw_dmd.parcel_store_stage_new pss
            join ph_staging.parcel_info pi on pss.pno = pi.pno
            left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
            where
                pi.returned = 1
                and pss.next_store_id = pi.dst_store_id
                and pss.van_left_at is not null
                and pss.van_plan_arrived_at >= curdate()
                and pss.next_store_id is not null
        ) a
    left join
        (
            select
                pr.pno
                ,pr.store_id
            from ph_staging.parcel_route pr
            join
                (
                    select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1
                ) a on pr.pno = a.pno
            where
                pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                and pr.routed_at > date_sub(curdate(), interval 8 hour)
        ) pr on coalesce(pr.pno,1) = coalesce(a.pno,0) and coalesce(a.next_store_id, 1) = coalesce(a.next_store_id, 0)
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        a.next_store_id store_id
        ,a.next_store_name store_name
        ,count(distinct a.pno) 应到退件包裹
        ,count(distinct (a.cod_enabled = 1, a.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , a.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and a.cod_enabled = 1, a.pno, null)) 实到退件COD包裹
        ,count(distinct if(a.state = 5, a.pno, null)) 退件妥投包裹
        ,count(distinct if(a.state = 5 and a.cod_enabled = 1, a.pno , null)) 退件妥投COD包裹
        ,count(distinct if(a.state = 5, a.pno, null))/count(distinct if(pr.pno is not null , a.pno, null)) 退件妥投完成率
        ,count(distinct if(a.state = 5 and a.cod_enabled = 1, a.pno, null))/count(distinct if(pr.pno is not null and a.cod_enabled = 1, a.pno, null)) COD退件妥投完成率
    from
        (
            select
                pi.state
                ,pss.pno
                ,pi2.cod_enabled
                ,pss.next_store_id
                ,pss.next_store_name
            from dw_dmd.parcel_store_stage_new pss
            join ph_staging.parcel_info pi on pss.pno = pi.pno
            left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
            where
                pi.returned = 1
                and pss.next_store_id = pi.dst_store_id
                and pss.van_left_at is not null
                and pss.van_plan_arrived_at >= curdate()
                and pss.next_store_id is not null
        ) a
    left join
        (
            select
                pr.pno
                ,pr.store_id
            from ph_staging.parcel_route pr
            join
                (
                    select
                        pss.pno
                    from dw_dmd.parcel_store_stage_new pss
                    join ph_staging.parcel_info pi on pss.pno = pi.pno
                    where
                        pss.van_left_at is not null
                        and pss.van_plan_arrived_at >= curdate()
                        and pss.next_store_id is not null
                        and pi.returned = 1
                ) a on pr.pno = a.pno
            where
                pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
                and pr.routed_at > date_sub(curdate(), interval 8 hour)
        ) pr on pr.pno = a.pno and a.next_store_id = a.next_store_id
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5, pss.pno and pi2.cod_enabled = 1, null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5, pss.pno and pi2.cod_enabled = 1, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pss.pno and pr.store_id = pss.next_store_id and pr.routed_at > date_sub(curdate(), interval 8 hour) and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at > curdate()
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.dst_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN' and pr.routed_at > date_sub(curdate(), interval 8 hour)
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at > curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
#         ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
#         ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
#         ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
#         ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
#     left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.dst_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN' and pr.routed_at > date_sub(curdate(), interval 8 hour)
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at >= curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
#         ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
#         ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
#         ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
#         ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.dst_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN' and pr.routed_at > date_sub(curdate(), interval 8 hour)
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at >= curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.dst_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at >= curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.dst_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at >= curdate()
        and pss.next_store_id is not null
        and pss.pno is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    left join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.store_id = pi.dst_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at >= curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    left join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pi.pno /*and pr.store_id = pi.dst_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'*/
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at >= curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
        pss.next_store_id store_id
        ,pss.next_store_name store_name
        ,count(distinct pss.pno) 应到退件包裹
        ,count(distinct (pi2.cod_enabled = 1, pss.pno, null)) 应到退件COD包裹
        ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
        ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
        ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
        ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    from dw_dmd.parcel_store_stage_new pss
    left join ph_staging.parcel_info pi on pss.pno = pi.pno
    left join ph_staging.parcel_info pi2 on pi2.returned_pno = pi.pno
    left join ph_staging.parcel_route pr on pr.pno = pss.pno /*and pr.store_id = pi.dst_store_id  and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'*/
    where
        pi.returned = 1
        and pss.next_store_id = pi.dst_store_id
        and pss.van_left_at is not null
        and pss.van_plan_arrived_at >= curdate()
        and pss.next_store_id is not null
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
    ,pr.store_id
from ph_staging.parcel_route pr
left join ph_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.next_store_id = ft.next_store_id
left join ph_staging.parcel_info pi on pi.pno = pr.pno
where
    pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    and pr.routed_at > date_sub(curdate(), interval 5 day)
    and ft.plan_arrive_time > date_sub(curdate(), interval 8 hour)
    and pi.returned = 1
    and pr.store_id = pi.dst_store_id
limit 100;
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
    ,pr.next_store_id
from ph_staging.parcel_route pr
left join ph_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.next_store_id = ft.next_store_id
left join ph_staging.parcel_info pi on pi.pno = pr.pno
where
    pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    and pr.routed_at > date_sub(curdate(), interval 5 day)
    and ft.plan_arrive_time > date_sub(curdate(), interval 8 hour)
    and pi.returned = 1
    and pr.store_id = pi.dst_store_id
limit 100;
;-- -. . -..- - / . -. - .-. -.--
select
#         pss.next_store_id store_id
#         ,pss.next_store_name store_name
#         ,count(distinct pr.pno) 应到退件包裹
#         ,count(distinct (pi2.cod_enabled = 1, pr.pno, null)) 应到退件COD包裹
#         ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
#         ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
#         ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
#         ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
#         ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
#         ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
        pr.next_store_id
        ,pr.next_store_name
        ,pr.pno
from ph_staging.parcel_route pr
left join ph_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.next_store_id = ft.next_store_id
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_info pi2 on  pi2.returned_pno = pi.pno
left join dwm.dwd_ex_ph_parcel_details de on de.pno = pr.pno
where
    pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    and pr.routed_at > date_sub(curdate(), interval 5 day)
    and ft.plan_arrive_time > date_sub(curdate(), interval 8 hour)
    and pi.returned = 1
    and pr.next_store_id = pi.dst_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
#         pss.next_store_id store_id
#         ,pss.next_store_name store_name
#         ,count(distinct pr.pno) 应到退件包裹
#         ,count(distinct (pi2.cod_enabled = 1, pr.pno, null)) 应到退件COD包裹
#         ,count(distinct if(pr.pno is not null , pss.pno, null)) 实到退件包裹
#         ,count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) 实到退件COD包裹
#         ,count(distinct if(pi.state = 5, pss.pno, null)) 退件妥投包裹
#         ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno , null)) 退件妥投COD包裹
#         ,count(distinct if(pi.state = 5, pss.pno, null))/count(distinct if(pr.pno is not null , pss.pno, null)) 退件妥投完成率
#         ,count(distinct if(pi.state = 5 and pi2.cod_enabled = 1, pss.pno, null))/count(distinct if(pr.pno is not null and pi2.cod_enabled = 1, pss.pno, null)) COD退件妥投完成率
    pr.next_store_id
    ,pr.next_store_name
    ,count(pr.pno) 应到退件包裹
    ,count(if(pi2.cod_enabled = 1, pr.pno, null)) 应到退件COD包裹
    ,count(if(de.dst_routed_at is not null , pr.pno, null)) 实到退件包裹
    ,count(if(de.dst_routed_at is not null and pi2.cod_enabled = 1, pr.pno, null)) 实到退件COD包裹
    ,count(if(pi.state = 5, pr.pno, null)) 退件妥投包裹
    ,count(if(pi.state = 5 and pi2.cod_enabled = 1, pr.pno, null)) 退件妥投COD包裹
    ,count(if(pi.state = 5, pr.pno, null))/count(if(de.dst_routed_at is not null , pr.pno, null)) 退件妥投完成率
    ,count(if(pi.state = 5 and pi2.cod_enabled = 1, pr.pno, null))/count(if(de.dst_routed_at is not null and pi2.cod_enabled = 1, pr.pno, null)) COD退件妥投完成率
from ph_staging.parcel_route pr
left join ph_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.next_store_id = ft.next_store_id
left join ph_staging.parcel_info pi on pi.pno = pr.pno
left join ph_staging.parcel_info pi2 on  pi2.returned_pno = pi.pno
left join dwm.dwd_ex_ph_parcel_details de on de.pno = pr.pno
where
    pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    and pr.routed_at > date_sub(curdate(), interval 5 day)
    and ft.plan_arrive_time > date_sub(curdate(), interval 8 hour)
    and pi.returned = 1
    and pr.next_store_id = pi.dst_store_id
    group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with s1 as
(
    select
        t1.dst_store_id store_id
        ,t1.dst_store store_name
        ,count(t1.pno) 在仓包裹数
        ,count(if(t1.cod_enabled = 'YES', t1.pno, null)) 在仓COD包裹数
        ,count(if(t1.days <= 3, t1.pno, null)) 3日内滞留
        ,count(if(t1.days <= 3 and t1.cod_enabled = 'YES', t1.pno, null)) 3日内COD滞留
        ,count(if(t1.days <= 5, t1.pno, null)) 5日内滞留
        ,count(if(t1.days <= 5 and t1.cod_enabled = 'YES', t1.pno, null)) 5日内COD滞留
        ,count(if(t1.days <= 7, t1.pno, null)) 7日内滞留
        ,count(if(t1.days <= 7 and t1.cod_enabled = 'YES', t1.pno, null)) 7日内COD滞留
        ,count(if(t1.days > 7, t1.pno, null)) 超7天滞留
        ,count(if(t1.days > 7 and t1.cod_enabled = 'YES', t1.pno, null)) 超7天COD滞留
        ,count(if(t1.client_name = 'lazada', t1.pno, null)) lazada在仓
        ,count(if(t1.client_name = 'lazada' and t1.cod_enabled = 'YES', t1.pno, null)) lazadaCOD在仓
        ,count(if(t1.client_name = 'shopee', t1.pno, null)) shopee在仓
        ,count(if(t1.client_name = 'shopee' and t1.cod_enabled = 'YES', t1.pno, null)) shopeeCOD在仓
        ,count(if(t1.client_name = 'tiktok', t1.pno, null)) tt在仓
        ,count(if(t1.client_name = 'tiktok' and t1.cod_enabled = 'YES', t1.pno, null)) ttCOD在仓
        ,count(if(t1.client_name = 'ka&c', t1.pno, null)) 'KA&小C在仓'
        ,count(if(t1.client_name = 'ka&c' and t1.cod_enabled = 'YES', t1.pno, null)) 'KA&小CCOD在仓'
    from
        (
            select
                de.pno
                ,de.dst_store_id
                ,de.dst_store
                ,if(bc.client_name is not null , bc.client_name, 'ka&c') client_name
                ,datediff(curdate(), de.dst_routed_at) days
                ,de.cod_enabled
            from dwm.dwd_ex_ph_parcel_details de
            left join dwm.dwd_dim_bigClient bc on bc.client_id = de.client_id
            where
                de.parcel_state not in (5,7,8,9)
                and de.dst_routed_at is not null
        ) t1
    group by 1
)
,s2 as
(
    select
        a1.dst_store_id store_id
        ,a1.dst_store store_name
        ,a1.num 当日到达COD包裹
        ,a2.num 当日交接COD包裹
        ,a3.num 当日妥投COD包裹
        ,a3.num/a1.num 当日到站COD妥投率
        ,a4.last_3day_num 3日内COD妥投包裹
        ,a4.last_3day_rate 3日COD妥投率
        ,a5.last_3_5day_num 5日COD妥投包裹
        ,a5.last_3_5day_rate 5日COD妥投率
        ,a6.last_5_7day_num 7日内COD包裹妥投数
        ,a6.last_5_7day_rate 7日COD妥投率
        ,a7.over_7day_num 超7日COD包裹妥投数
        ,a7.over_7day_rate 超7日COD妥投率
    from
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) num
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.dst_routed_at >= date_sub(curdate(), interval 8 hour )
                and de.dst_routed_at < date_add(curdate(), interval 16 hour)
                and de.cod_enabled = 'YES'
            group by 1,2
        ) a1
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) num
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.dst_routed_at >= date_sub(curdate(), interval 8 hour )
                and de.dst_routed_at < date_add(curdate(), interval 16 hour)
                and de.first_scan_time >= date_sub(curdate(), interval 8 hour )
                and de.first_scan_time < date_add(curdate(), interval 16 hour)
                and de.cod_enabled = 'YES'
            group by 1,2
        ) a2  on a2.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) num
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.dst_routed_at >= date_sub(curdate(), interval 8 hour )
                and de.dst_routed_at < date_add(curdate(), interval 16 hour)
                and de.finished_date = curdate()
                and de.parcel_state = 5
                and de.cod_enabled = 'YES'
            group by 1,2
        ) a3 on a3.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) sh_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null)) last_3day_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null))/count(de.pno) last_3day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.dst_routed_at >= date_sub(date_sub(curdate(), interval 3 day), interval 8 hour) -- 3天前到达
                and de.dst_routed_at < date_add(date_sub(curdate(), interval 3 day), interval 16 hour) -- 3天前到达
            group by 1,2
         ) a4 on a4.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) sh_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null)) last_3_5day_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null))/count(de.pno) last_3_5day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.dst_routed_at >= date_sub(date_sub(curdate(), interval 5 day), interval 8 hour) -- 3天前到达
                and de.dst_routed_at < date_add(date_sub(curdate(), interval 5 day), interval 16 hour) -- 3天前到达
            group by 1,2
        ) a5 on a5.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) sh_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null)) last_5_7day_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null))/count(de.pno) last_5_7day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.dst_routed_at >= date_sub(date_sub(curdate(), interval 7 day), interval 8 hour) -- 3天前到达
                and de.dst_routed_at < date_add(date_sub(curdate(), interval 7 day), interval 16 hour) -- 3天前到达
            group by 1,2
        ) a6 on a6.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(if(de.parcel_state = 5 and datediff(de.finished_date, de.dst_routed_at) > 7 , de.pno, null)) over_7day_num
                ,count(if(de.parcel_state = 5 and datediff(de.finished_date, de.dst_routed_at) > 7 , de.pno, null))/count(de.pno) over_7day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.parcel_state < 9
                and
                    (
                        ( de.parcel_state not in (5,7,8,9) and de.dst_routed_at < date_sub(date_sub(curdate(), interval 7 day), interval 8 hour))
                        or ( de.parcel_state in (5,7,8) and de.updated_at > date_sub(date_sub(curdate(), interval 7 day), interval 8 hour) and de.dst_routed_at < date_sub(date_sub(curdate(), interval 7 day), interval 8 hour))
                    )
            group by 1,2
        ) a7 on a7.dst_store_id = a1.dst_store_id
)
,s3 as
-- 应退件
(
    select
        de.dst_store_id store_id
        ,de.dst_store  store_name
        ,count(t.pno)  应退件包裹
        ,count(if(de.cod_enabled = 'YES', de.pno, null)) 应退件COD包裹
        ,count(if(de.return_time is not null, de.pno, null)) 实际退件包裹
        ,count(if(de.return_time is not null and de.cod_enabled = 'YES', de.pno, null)) 实际退件COD包裹
        ,count(if(de.return_time is not null, de.pno, null))/count(t.pno) 退件操作完成率
        ,count(if(de.return_time is not null and de.cod_enabled = 'YES', de.pno, null))/count(if(de.cod_enabled = 'YES', de.pno, null)) COD退件操作完成率
    from
        (
            select
                pr.pno
            from ph_staging.parcel_route pr
            where
                pr.routed_at > date_sub(curdate(), interval 8 hour)
                and pr.route_action = 'PENDING_RETURN' -- 待退件
            group by 1
        ) t
    join dwm.dwd_ex_ph_parcel_details de on t.pno = de.pno
    group by 1,2
)
,s4 as
(
    select
        pr.next_store_id store_id
        ,pr.next_store_name store_name
        ,count(pr.pno) 应到退件包裹
        ,count(if(pi2.cod_enabled = 1, pr.pno, null)) 应到退件COD包裹
        ,count(if(de.dst_routed_at is not null , pr.pno, null)) 实到退件包裹
        ,count(if(de.dst_routed_at is not null and pi2.cod_enabled = 1, pr.pno, null)) 实到退件COD包裹
        ,count(if(pi.state = 5, pr.pno, null)) 退件妥投包裹
        ,count(if(pi.state = 5 and pi2.cod_enabled = 1, pr.pno, null)) 退件妥投COD包裹
        ,count(if(pi.state = 5, pr.pno, null))/count(if(de.dst_routed_at is not null , pr.pno, null)) 退件妥投完成率
        ,count(if(pi.state = 5 and pi2.cod_enabled = 1, pr.pno, null))/count(if(de.dst_routed_at is not null and pi2.cod_enabled = 1, pr.pno, null)) COD退件妥投完成率
    from ph_staging.parcel_route pr
    left join ph_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.next_store_id = ft.next_store_id
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    left join ph_staging.parcel_info pi2 on  pi2.returned_pno = pi.pno
    left join dwm.dwd_ex_ph_parcel_details de on de.pno = pr.pno
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day)
        and ft.plan_arrive_time > date_sub(curdate(), interval 8 hour)
        and pi.returned = 1
        and pr.next_store_id = pi.dst_store_id
    group by 1,2
)
select
    ss.store_id
    ,ss.store_name
    ,s1.在仓包裹数, s1.在仓COD包裹数, s1.`3日内滞留`, s1.`3日内COD滞留`, s1.`5日内滞留`, s1.`5日内COD滞留`, s1.`7日内滞留`, s1.`7日内COD滞留`, s1.超7天滞留, s1.超7天COD滞留, s1.lazada在仓, s1.lazadaCOD在仓, s1.shopee在仓, s1.shopeeCOD在仓, s1.tt在仓, s1.ttCOD在仓, s1.`KA&小C在仓`, s1.`KA&小CCOD在仓`
    ,s2.当日到达COD包裹, s2.当日交接COD包裹, s2.当日妥投COD包裹, s2.当日到站COD妥投率, s2.`3日内COD妥投包裹`, s2.`3日COD妥投率`, s2.`5日COD妥投包裹`, s2.`5日COD妥投率`, s2.`7日内COD包裹妥投数`, s2.`7日COD妥投率`, s2.超7日COD包裹妥投数, s2.超7日COD妥投率
    ,s3.应退件包裹, s3.应退件COD包裹, s3.实际退件包裹, s3.实际退件COD包裹, s3.退件操作完成率, s3.COD退件操作完成率
    ,s4.应到退件包裹, s4.应到退件COD包裹, s4.实到退件包裹, s4.实到退件COD包裹, s4.退件妥投包裹, s4.退件妥投COD包裹, s4.退件妥投完成率, s4.COD退件妥投完成率
from
    (
        select s1.store_id,s1.store_name from s1 group by 1,2
        union all
        select s2.store_id,s2.store_name from s2 group by 1,2
        union all
        select s3.store_id,s3.store_name from s3 group by 1,2
        union all
        select s4.store_id,s4.store_name from s4 group by 1,2
    ) ss
left join s1 on s1.store_id = ss.store_id
left join s2 on s2.store_id = ss.store_id
left join s3 on s3.store_id = ss.store_id
left join s4 on s4.store_id = ss.store_id;
;-- -. . -..- - / . -. - .-. -.--
with s1 as
(
    select
        t1.dst_store_id store_id
        ,t1.dst_store store_name
        ,count(t1.pno) 在仓包裹数
        ,count(if(t1.cod_enabled = 'YES', t1.pno, null)) 在仓COD包裹数
        ,count(if(t1.days <= 3, t1.pno, null)) 3日内滞留
        ,count(if(t1.days <= 3 and t1.cod_enabled = 'YES', t1.pno, null)) 3日内COD滞留
        ,count(if(t1.days <= 5, t1.pno, null)) 5日内滞留
        ,count(if(t1.days <= 5 and t1.cod_enabled = 'YES', t1.pno, null)) 5日内COD滞留
        ,count(if(t1.days <= 7, t1.pno, null)) 7日内滞留
        ,count(if(t1.days <= 7 and t1.cod_enabled = 'YES', t1.pno, null)) 7日内COD滞留
        ,count(if(t1.days > 7, t1.pno, null)) 超7天滞留
        ,count(if(t1.days > 7 and t1.cod_enabled = 'YES', t1.pno, null)) 超7天COD滞留
        ,count(if(t1.client_name = 'lazada', t1.pno, null)) lazada在仓
        ,count(if(t1.client_name = 'lazada' and t1.cod_enabled = 'YES', t1.pno, null)) lazadaCOD在仓
        ,count(if(t1.client_name = 'shopee', t1.pno, null)) shopee在仓
        ,count(if(t1.client_name = 'shopee' and t1.cod_enabled = 'YES', t1.pno, null)) shopeeCOD在仓
        ,count(if(t1.client_name = 'tiktok', t1.pno, null)) tt在仓
        ,count(if(t1.client_name = 'tiktok' and t1.cod_enabled = 'YES', t1.pno, null)) ttCOD在仓
        ,count(if(t1.client_name = 'ka&c', t1.pno, null)) 'KA&小C在仓'
        ,count(if(t1.client_name = 'ka&c' and t1.cod_enabled = 'YES', t1.pno, null)) 'KA&小CCOD在仓'
    from
        (
            select
                de.pno
                ,de.dst_store_id
                ,de.dst_store
                ,if(bc.client_name is not null , bc.client_name, 'ka&c') client_name
                ,datediff(curdate(), de.dst_routed_at) days
                ,de.cod_enabled
            from dwm.dwd_ex_ph_parcel_details de
            left join dwm.dwd_dim_bigClient bc on bc.client_id = de.client_id
            where
                de.parcel_state not in (5,7,8,9)
                and de.dst_routed_at is not null
        ) t1
    group by 1
)
,s2 as
(
    select
        a1.dst_store_id store_id
        ,a1.dst_store store_name
        ,a1.num 当日到达COD包裹
        ,a2.num 当日交接COD包裹
        ,a3.num 当日妥投COD包裹
        ,a3.num/a1.num 当日到站COD妥投率
        ,a4.last_3day_num 3日内COD妥投包裹
        ,a4.last_3day_rate 3日COD妥投率
        ,a5.last_3_5day_num 5日COD妥投包裹
        ,a5.last_3_5day_rate 5日COD妥投率
        ,a6.last_5_7day_num 7日内COD包裹妥投数
        ,a6.last_5_7day_rate 7日COD妥投率
        ,a7.over_7day_num 超7日COD包裹妥投数
        ,a7.over_7day_rate 超7日COD妥投率
    from
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) num
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.dst_routed_at >= date_sub(curdate(), interval 8 hour )
                and de.dst_routed_at < date_add(curdate(), interval 16 hour)
                and de.cod_enabled = 'YES'
            group by 1,2
        ) a1
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) num
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.dst_routed_at >= date_sub(curdate(), interval 8 hour )
                and de.dst_routed_at < date_add(curdate(), interval 16 hour)
                and de.first_scan_time >= date_sub(curdate(), interval 8 hour )
                and de.first_scan_time < date_add(curdate(), interval 16 hour)
                and de.cod_enabled = 'YES'
            group by 1,2
        ) a2  on a2.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) num
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.dst_routed_at >= date_sub(curdate(), interval 8 hour )
                and de.dst_routed_at < date_add(curdate(), interval 16 hour)
                and de.finished_date = curdate()
                and de.parcel_state = 5
                and de.cod_enabled = 'YES'
            group by 1,2
        ) a3 on a3.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) sh_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null)) last_3day_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null))/count(de.pno) last_3day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.dst_routed_at >= date_sub(date_sub(curdate(), interval 3 day), interval 8 hour) -- 3天前到达
                and de.dst_routed_at < date_add(date_sub(curdate(), interval 3 day), interval 16 hour) -- 3天前到达
            group by 1,2
         ) a4 on a4.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) sh_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null)) last_3_5day_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null))/count(de.pno) last_3_5day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.dst_routed_at >= date_sub(date_sub(curdate(), interval 5 day), interval 8 hour) -- 3天前到达
                and de.dst_routed_at < date_add(date_sub(curdate(), interval 5 day), interval 16 hour) -- 3天前到达
            group by 1,2
        ) a5 on a5.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(de.pno) sh_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null)) last_5_7day_num
                ,count(if(de.parcel_state = 5 and de.finished_date > date_sub(curdate(), interval 3 day), de.pno, null))/count(de.pno) last_5_7day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.dst_routed_at >= date_sub(date_sub(curdate(), interval 7 day), interval 8 hour) -- 3天前到达
                and de.dst_routed_at < date_add(date_sub(curdate(), interval 7 day), interval 16 hour) -- 3天前到达
            group by 1,2
        ) a6 on a6.dst_store_id = a1.dst_store_id
    left join
        (
            select
                de.dst_store_id
                ,de.dst_store
                ,count(if(de.parcel_state = 5 and datediff(de.finished_date, de.dst_routed_at) > 7 , de.pno, null)) over_7day_num
                ,count(if(de.parcel_state = 5 and datediff(de.finished_date, de.dst_routed_at) > 7 , de.pno, null))/count(de.pno) over_7day_rate
            from dwm.dwd_ex_ph_parcel_details de
            where
                de.cod_enabled = 'YES'
                and de.parcel_state < 9
                and
                    (
                        ( de.parcel_state not in (5,7,8,9) and de.dst_routed_at < date_sub(date_sub(curdate(), interval 7 day), interval 8 hour))
                        or ( de.parcel_state in (5,7,8) and de.updated_at > date_sub(date_sub(curdate(), interval 7 day), interval 8 hour) and de.dst_routed_at < date_sub(date_sub(curdate(), interval 7 day), interval 8 hour))
                    )
            group by 1,2
        ) a7 on a7.dst_store_id = a1.dst_store_id
)
,s3 as
-- 应退件
(
    select
        de.dst_store_id store_id
        ,de.dst_store  store_name
        ,count(t.pno)  应退件包裹
        ,count(if(de.cod_enabled = 'YES', de.pno, null)) 应退件COD包裹
        ,count(if(de.return_time is not null, de.pno, null)) 实际退件包裹
        ,count(if(de.return_time is not null and de.cod_enabled = 'YES', de.pno, null)) 实际退件COD包裹
        ,count(if(de.return_time is not null, de.pno, null))/count(t.pno) 退件操作完成率
        ,count(if(de.return_time is not null and de.cod_enabled = 'YES', de.pno, null))/count(if(de.cod_enabled = 'YES', de.pno, null)) COD退件操作完成率
    from
        (
            select
                pr.pno
            from ph_staging.parcel_route pr
            where
                pr.routed_at > date_sub(curdate(), interval 8 hour)
                and pr.route_action = 'PENDING_RETURN' -- 待退件
            group by 1
        ) t
    join dwm.dwd_ex_ph_parcel_details de on t.pno = de.pno
    group by 1,2
)
,s4 as
(
    select
        pr.next_store_id store_id
        ,pr.next_store_name store_name
        ,count(pr.pno) 应到退件包裹
        ,count(if(pi2.cod_enabled = 1, pr.pno, null)) 应到退件COD包裹
        ,count(if(de.dst_routed_at is not null , pr.pno, null)) 实到退件包裹
        ,count(if(de.dst_routed_at is not null and pi2.cod_enabled = 1, pr.pno, null)) 实到退件COD包裹
        ,count(if(pi.state = 5, pr.pno, null)) 退件妥投包裹
        ,count(if(pi.state = 5 and pi2.cod_enabled = 1, pr.pno, null)) 退件妥投COD包裹
        ,count(if(pi.state = 5, pr.pno, null))/count(if(de.dst_routed_at is not null , pr.pno, null)) 退件妥投完成率
        ,count(if(pi.state = 5 and pi2.cod_enabled = 1, pr.pno, null))/count(if(de.dst_routed_at is not null and pi2.cod_enabled = 1, pr.pno, null)) COD退件妥投完成率
    from ph_staging.parcel_route pr
    left join ph_bi.fleet_time ft on ft.proof_id = json_extract(pr.extra_value, '$.proofId') and pr.next_store_id = ft.next_store_id
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    left join ph_staging.parcel_info pi2 on  pi2.returned_pno = pi.pno
    left join dwm.dwd_ex_ph_parcel_details de on de.pno = pr.pno
    where
        pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 5 day)
        and ft.plan_arrive_time > date_sub(curdate(), interval 8 hour)
        and pi.returned = 1
        and pr.next_store_id = pi.dst_store_id
    group by 1,2
)
select
    ss.store_id
    ,ss.store_name
    ,s1.在仓包裹数, s1.在仓COD包裹数, s1.`3日内滞留`, s1.`3日内COD滞留`, s1.`5日内滞留`, s1.`5日内COD滞留`, s1.`7日内滞留`, s1.`7日内COD滞留`, s1.超7天滞留, s1.超7天COD滞留, s1.lazada在仓, s1.lazadaCOD在仓, s1.shopee在仓, s1.shopeeCOD在仓, s1.tt在仓, s1.ttCOD在仓, s1.`KA&小C在仓`, s1.`KA&小CCOD在仓`
    ,s2.当日到达COD包裹, s2.当日交接COD包裹, s2.当日妥投COD包裹, s2.当日到站COD妥投率, s2.`3日内COD妥投包裹`, s2.`3日COD妥投率`, s2.`5日COD妥投包裹`, s2.`5日COD妥投率`, s2.`7日内COD包裹妥投数`, s2.`7日COD妥投率`, s2.超7日COD包裹妥投数, s2.超7日COD妥投率
    ,s3.应退件包裹, s3.应退件COD包裹, s3.实际退件包裹, s3.实际退件COD包裹, s3.退件操作完成率, s3.COD退件操作完成率
    ,s4.应到退件包裹, s4.应到退件COD包裹, s4.实到退件包裹, s4.实到退件COD包裹, s4.退件妥投包裹, s4.退件妥投COD包裹, s4.退件妥投完成率, s4.COD退件妥投完成率
from
    (
        select s1.store_id,s1.store_name from s1 group by 1,2
        union
        select s2.store_id,s2.store_name from s2 group by 1,2
        union
        select s3.store_id,s3.store_name from s3 group by 1,2
        union
        select s4.store_id,s4.store_name from s4 group by 1,2
    ) ss
left join s1 on s1.store_id = ss.store_id
left join s2 on s2.store_id = ss.store_id
left join s3 on s3.store_id = ss.store_id
left join s4 on s4.store_id = ss.store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    json_table(pre.extra_value)
from ph_drds.parcel_route_extra pre
where
    pre.id = '14169159';
;-- -. . -..- - / . -. - .-. -.--
select
    a.id
from ph_drds.parcel_route_extra pre,json_table(pre.extra_value,'$[*]' ,columns(id int path '$images')) as a
where
    pre.id = '14169159';
;-- -. . -..- - / . -. - .-. -.--
select
    a.id
from ph_drds.parcel_route_extra pre,json_table(pre.extra_value,'$[*]' ,columns(id VARCHAR(100) path '$images')) as a
where
    pre.id = '14169159';
;-- -. . -..- - / . -. - .-. -.--
select version();
;-- -. . -..- - / . -. - .-. -.--
select
    json_extract(pre.extra_value, '$.images')
from ph_drds.parcel_route_extra pre
where
    pre.id = '14169159';
;-- -. . -..- - / . -. - .-. -.--
select
    json_unquote(json_extract(pre.extra_value, '$.images'))
from ph_drds.parcel_route_extra pre
where
    pre.id = '14169159';
;-- -. . -..- - / . -. - .-. -.--
select
    explode(json_extract(pre.extra_value, '$.images'))
from ph_drds.parcel_route_extra pre
where
    pre.id = '14169159';
;-- -. . -..- - / . -. - .-. -.--
select
    replace(json_extract(pre.extra_value, '$.images'), '"','')
from ph_drds.parcel_route_extra pre
where
    pre.id = '14169159';
;-- -. . -..- - / . -. - .-. -.--
select
    replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '')
from ph_drds.parcel_route_extra pre
where
    pre.id = '14169159';
;-- -. . -..- - / . -. - .-. -.--
select
    *
     ,concat('{',job_title,'}') json_test
     ,JSON_EXTRACT(concat('{',job_title,'}'),'$.id')
     ,JSON_EXTRACT(concat('{',job_title,'}'),'$.driver')
from
    (
    SELECT
        id
         , after_object
         ,replace( REPLACE(after_object, '[{',''),'}]','') as new
    from ph_staging.record_version_info rvi
    where id=383553
    )t
    lateral VIEW posexplode ( split ( new, '},{' ) ) t AS job_title, val;
;-- -. . -..- - / . -. - .-. -.--
select
    replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '')
from ph_drds.parcel_route_extra pre

where
    pre.id = '14169159'
lateral view posexplode(split, ',') as b;
;-- -. . -..- - / . -. - .-. -.--
select
    replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '')
from ph_drds.parcel_route_extra pre

lateral view posexplode(split, ',') b as b

where
    pre.id = '14169159';
;-- -. . -..- - / . -. - .-. -.--
select
    *
from
    (
        select
            replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
        from ph_drds.parcel_route_extra pre
        where
            pre.id = '14169159'
    ) a
lateral view explode(split(a.valu, ',')) as id;
;-- -. . -..- - / . -. - .-. -.--
select
    id
from
    (
        select
            replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
        from ph_drds.parcel_route_extra pre
        where
            pre.id = '14169159'
    ) a
lateral view explode(split(a.valu, ',')) as id;
;-- -. . -..- - / . -. - .-. -.--
select
    id
from
    (
        select
            replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
        from ph_drds.parcel_route_extra pre
        where
            pre.id = '14169159'
    ) a
lateral view explode(split(a.valu, ',')) id as id;
;-- -. . -..- - / . -. - .-. -.--
select
    id
from
    (
        select
            replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
        from ph_drds.parcel_route_extra pre
        where
            pre.id = '14169159'
    ) a
lateral view explode(split(a.valu, ',')) id;
;-- -. . -..- - / . -. - .-. -.--
select
    id
from
    (
        select
            replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
        from ph_drds.parcel_route_extra pre
        where
            pre.id = '14169159'
    ) a
lateral view explode(split(a.valu, ',')) id as c;
;-- -. . -..- - / . -. - .-. -.--
select
    c
from
    (
        select
            replace(replace(replace(json_extract(pre.extra_value, '$.images'), '"', ''),'[', ''),']', '') valu
        from ph_drds.parcel_route_extra pre
        where
            pre.id = '14169159'
    ) a
lateral view explode(split(a.valu, ',')) id as c;
;-- -. . -..- - / . -. - .-. -.--
select
                *
#                     json_extract(ext_info,'$.organization_id') store_id
#                     ,substr(fp.p_date, 1, 4) p_month
#                     ,count(if(fp.event_type = 'screenView', fp.user_id, null)) view_num
#                     ,count(distinct if(fp.event_type = 'screenView', fp.user_id, null)) view_staff_num
#                     ,count(if(fp.event_type = 'click' and fp.button_id = 'search', fp.user_id, null)) search_num
#                     ,count(if(fp.event_type = 'click' and fp.button_id = 'match', fp.user_id, null)) match_num
#                     ,count(if(json_unquote(json_extract(ext_info,'$.matchResult')) = 'true', fp.user_id, null)) sucess_num
                from dwm.dwd_ph_sls_pro_flash_point fp
                where
                    fp.p_date >= '2023-01-01'
                    and fp.store_id = 'PH04470200'
                    and json_unquote(json_extract(ext_info,'$.matchResult')) = 'true';
;-- -. . -..- - / . -. - .-. -.--
select
                *
#                     json_extract(ext_info,'$.organization_id') store_id
#                     ,substr(fp.p_date, 1, 4) p_month
#                     ,count(if(fp.event_type = 'screenView', fp.user_id, null)) view_num
#                     ,count(distinct if(fp.event_type = 'screenView', fp.user_id, null)) view_staff_num
#                     ,count(if(fp.event_type = 'click' and fp.button_id = 'search', fp.user_id, null)) search_num
#                     ,count(if(fp.event_type = 'click' and fp.button_id = 'match', fp.user_id, null)) match_num
#                     ,count(if(json_unquote(json_extract(ext_info,'$.matchResult')) = 'true', fp.user_id, null)) sucess_num
                from dwm.dwd_ph_sls_pro_flash_point fp
                where
                    fp.p_date >= '2023-01-01'
                    and json_extract(ext_info,'$.organization_id') = 'PH04470200'
                    and json_unquote(json_extract(ext_info,'$.matchResult')) = 'true';
;-- -. . -..- - / . -. - .-. -.--
select
                    ph.hno
                    ,substr(ph.created_at, 1, 4) creat_month
                    ,ph.submit_store_name
                    ,ph.submit_store_id
                    ,ph.pno
                    ,case
                        when ph.state = 0 then '未认领_待认领'
                        when ph.state = 2 then '认领成功'
                        when ph.state = 3 and ph.claim_store_id is null then '未认领_已失效'
                        when ph.state = 3 and ph.claim_store_id is not null and ph.claim_at < coalesce(sx.claim_time,curdate()) then '认领成功_已失效'
                        when ph.state = 3 and ph.claim_store_id is not null and ph.claim_at >= coalesce(sx.claim_time,curdate()) then '认领失败_已失效' -- 理赔失效
                    end head_state
                    ,ph.state
                    ,ph.claim_store_id
                    ,ph.claim_store_name
                    ,ph.claim_at
                from  ph_staging.parcel_headless ph
                left join
                    (
                        select
                            ph.pno
                            ,min(pct.created_at) claim_time
                        from ph_staging.parcel_headless ph
                        join ph_bi.parcel_claim_task pct on pct.pno = ph.pno
                        where
                            ph.state = 3 -- 时效
                        group by 1
                    ) sx on sx.pno = ph.pno
                where
                    ph.state < 4
                    and ph.created_at >= '2023-04-01'
                    and ph.submit_store_id = 'PH19280F01';
;-- -. . -..- - / . -. - .-. -.--
select
                    ph.hno
                    ,substr(ph.created_at, 1, 4) creat_month
                    ,ph.submit_store_name
                    ,ph.submit_store_id
                    ,ph.pno
                    ,case
                        when ph.state = 0 then '未认领_待认领'
                        when ph.state in (1,2) then '认领成功'
                        when ph.state = 3 and ph.claim_store_id is null then '未认领_已失效'
                        when ph.state = 3 and ph.claim_store_id is not null and ph.claim_at < coalesce(sx.claim_time,curdate()) then '认领成功_已失效'
                        when ph.state = 3 and ph.claim_store_id is not null and ph.claim_at >= coalesce(sx.claim_time,curdate()) then '认领失败_已失效' -- 理赔失效
                    end head_state
                    ,ph.state
                    ,ph.claim_store_id
                    ,ph.claim_store_name
                    ,ph.claim_at
                from  ph_staging.parcel_headless ph
                left join
                    (
                        select
                            ph.pno
                            ,min(pct.created_at) claim_time
                        from ph_staging.parcel_headless ph
                        join ph_bi.parcel_claim_task pct on pct.pno = ph.pno
                        where
                            ph.state = 3 -- 时效
                        group by 1
                    ) sx on sx.pno = ph.pno
                where
                    ph.state < 4
                    and ph.created_at >= '2023-04-01'
                    and ph.submit_store_id = 'PH19280F01';