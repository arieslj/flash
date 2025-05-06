select
    pi.client_id
    ,pi.dst_phone 收件人
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,count(distinct pi.pno) 总包裹数
    ,count(distinct di.pno) 拒收包裹数
from ph_staging.parcel_info pi
left join ph_staging.diff_info di on pi.pno = di.pno and di.diff_marker_category in (2,17)
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = coalesce(di.store_id, pi.dst_store_id) and dp.stat_date = date_sub(curdate(), interval 1 day )
where
    pi.returned = 0
    and pi.state < 9
    and pi.client_id in ('CA0089','BA0635','A0142','BA0184','BA0056','BA0299','BA0577','CA3484','BA0258','CA1026','BA0323','BA0344','CA1644','BA0599','AA0140','CA1281','CA0548','CA0179','CA1280','CA1385','CA3478','BA0391','AA0111','AA0076','BA0441')
    and pi.created_at >= '2023-06-30 16:00:00'
    and pi.created_at < '2023-07-31 16:00:00'
group by 1,2,3


;




select
    pi.pno
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 'pickup time'
    ,src_name 'sender name'
    ,src_phone 'sender contact'
    ,pi.dst_name 'Consignee name'
    ,pi.dst_phone 'Consignee number'
    ,pi.dst_detail_address 'Consignee address'
    ,dp1.store_name 'pickup dc'
    ,dp1.piece_name 'pickup district'
    ,dp1.region_name 'pickup area'
    ,concat(hsi.name, '(', hsi.staff_info_id, ')') 'pickup courier'
    ,pi.cod_amount/100 COD
    ,pi.exhibition_weight 'weight/g'
    ,dp2.store_name 'destination dc'
    ,dp2.piece_name 'destination district'
    ,dp2.region_name 'destination area'
from ph_staging.parcel_info pi
left join dwm.dim_ph_sys_store_rd dp1 on dp1.store_id = pi.ticket_pickup_store_id and dp1.stat_date = date_sub(curdate(), interval 1 day )
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = pi.dst_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day )
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pi.ticket_pickup_staff_info_id
where
    if(hour(now()) >= 17, pi.created_at > date_sub(curdate(), interval 8 hour ) and pi.created_at <= date_add(curdate(), interval 9 hour), pi.created_at > date_sub(curdate(), interval 15 hour) and pi.created_at < date_sub(curdate(), interval 8 hour) )


;


select
    kp.id 客户ID
    ,ss.id 网点ID
    ,ss.name 网点
    ,count(distinct pi.pno) 总包裹数
    ,count(distinct if(pr.pno is not null , pi.pno, null)) 总拒收包裹数
    ,count(distinct if(pi.cod_enabled = 1, pi.pno, null)) COD包裹数
    ,count(distinct if(pr.pno is not null and pi.cod_enabled = 1, pi.pno, null)) COD拒收包裹数
from ph_staging.parcel_info pi
join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.parcel_route pr on pr.pno = pi.pno and pr.marker_category in (2,17)
left join ph_staging.sys_store ss on ss.id = coalesce(pi.ticket_delivery_store_id, dst_store_id)
where
    pi.returned = 0
    and pi.state < 9
    and pi.created_at >= '2023-06-30 16:00:00'
    and pi.created_at < '2023-07-31 16:00:00'
    and bc.client_id is null
group by 1,2,3


;



select
    ds.pno
    ,if(ds.arrival_scan_route_at < curdate(), '昨天', '今天' ) 包裹日期
from ph_bi.dc_should_delivery_today ds
where
    ds.stat_date = '2023-08-01'
#     and ds.store_id = 'PH61280100'
    and ds.pno = 'P61281YPAE8CN'
;

SELECT
	plt.`pno`  运单号
    ,plt.created_at 任务生成时间
    ,CONCAT('SSRD',plt.`id`) 任务ID
    ,case plt.`vip_enable`
    when 0 then '普通客户'
    when 1 then 'KAM客户'
    end as 客户类型
    ,plt.`client_id` 客户ID
    ,ss.`name` 始发地
    ,ss1.`name` 目的地
    ,if(plt.`fleet_routeids` is null,'一致','不一致') 解封车是否异常
    ,plt.`fleet_stores` 异常区间
    ,ft.`line_name`  异常车线
    ,plt.`parcel_created_at` 揽收时间
    ,case plt.`last_valid_action`
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
end as '最后有效路由'
 ,plt.`last_valid_staff_info_id` 最后操作人
 ,ss2.`name` 最后有效路由操作网点
 ,if(plt.`is_abnormal`=1,'是','否')  是否异常
 ,pr.`next_store_name`  下一站点
 ,wo.`order_no` 工单号
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
		END AS '问题件来源渠道'
  ,case plt.`state`
  when 1 then '待处理'
  when 2 then '待处理'
  when 3 then '待处理'
  when 4 then '待处理'
  when 5 then '包裹未丢失'
  when 6 then '丢失件处理完成'
  end as '状态'
  ,plt.`operator_id` 处理人
  ,plt.`updated_at` 处理时间
FROM  `ph_bi`.`parcel_lose_task` plt
LEFT JOIN `ph_staging`.`parcel_info`  pi on pi.pno = plt.pno
LEFT JOIN `ph_bi`.`sys_store` ss on ss.id = pi.`ticket_pickup_store_id`
LEFT JOIN `ph_bi`.`sys_store` ss1 on ss1.id = pi.`dst_store_id`
LEFT JOIN `ph_bi`.`sys_store` ss2 on ss2.id = plt.`last_valid_store_id`
LEFT JOIN `ph_staging`.`parcel_route` pr on pr.`pno` = plt.`pno` and pr.`store_id` = plt.`last_valid_store_id`
LEFT JOIN `ph_bi`.`work_order` wo on wo.`loseparcel_task_id` = plt.`id`
LEFT JOIN ph_bi.`fleet_time` ft on ft.`proof_id` =LEFT (plt.`fleet_routeids`,11)
where 1=1 and plt.`state` in (1,2,3,4)
and  DATE_FORMAT(plt.created_at ,'%Y%m%d')=curdate()
;

SELECT DISTINCT
	plt.`pno`  运单号
    ,t.cod
    ,t.cogs
	,plt.created_at 任务生成时间
    ,CONCAT('SSRD',plt.`id`) 任务ID
	,case plt.`vip_enable`
    when 0 then '普通客户'
    when 1 then 'KAM客户'
    end as 客户类型
	,case plt.`duty_result`
	when 1 then '丢失'
	when 2 then '破损'
	end as '判责类型'
	,t.`t_value` 原因
	,plt.`client_id` 客户ID
	,if(plt.`fleet_routeids` is null,'一致','不一致') 解封车是否异常
    ,plt.`fleet_stores` 异常区间
    ,ft.`line_name`  异常车线
        ,plt.`parcel_created_at` 揽收时间
    ,case plt.`last_valid_action`
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
end as '最后有效路由'
 ,ss2.`name` 最后有效路由操作网点
 ,if(plt.`is_abnormal`=1,'是','否')  是否异常
 ,pr.`next_store_name`  下一站点
	,wo.`order_no` 工单号
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
		END AS '问题件来源渠道'
	,case plt.`state`
	when 5 then '无需追责'
	when 6 then '责任人已认定'
	end  状态
	,plt.`operator_id` 处理人
	,plt.`updated_at` 处理时间
	,case if(plt.state= 6,pld.`duty_type`,null)
	when 1 then	'快递员100%套餐'
	when 10	 then	'双黄套餐(计数网点仓管40%计数网点主管10%对接分拨仓管40%对接分拨主管10%)'
	when 19	 then	'双黄套餐(计数网点仓管40%计数网点主管10%对接分拨仓管40%对接分拨主管10%)'
	when 2	 then	'仓9主1套餐(仓管90%主管10%)'
	when 20	 then	'加盟商双黄套餐（加盟商50%网点仓管45%主管5%)'
	when 3	 then	'仓9主1套餐(仓管90%主管10%)'
	when 4	 then	'双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
	when 5	 then	'快递员721套餐(快递员70%仓管20%主管10%)'
	when 6	 then	'仓管721套餐(仓管70%快递员20%主管10%)'
	when 7	 then	'其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
	when 8	 then	'LH全责（LH100%)'
	when 9	 then	'加盟商套餐'
	end as '套餐'
	,group_concat(distinct ss3.name) 责任网点
FROM  `ph_bi`.`parcel_lose_task` plt
LEFT JOIN `ph_staging`.`parcel_info`  pi on pi.pno = plt.pno
LEFT JOIN `ph_bi`.`sys_store` ss on ss.id = pi.`ticket_pickup_store_id`
LEFT JOIN `ph_bi`.`sys_store` ss1 on ss1.id = pi.`dst_store_id`
LEFT JOIN `ph_bi`.`sys_store` ss2 on ss2.id = plt.`last_valid_store_id`
LEFT JOIN `ph_staging`.`parcel_route` pr on pr.`pno` = plt.`pno` and pr.`store_id` = plt.`last_valid_store_id`
LEFT JOIN `ph_bi`.`work_order` wo on wo.`loseparcel_task_id` = plt.`id`
LEFT JOIN `ph_bi`.`fleet_time` ft on ft.`proof_id` =LEFT (plt.`fleet_routeids`,11)
LEFT JOIN `ph_bi`.`parcel_lose_stat_detail` pld on pld. `lose_task_id`=plt.`id`
LEFT JOIN `ph_bi`.`parcel_lose_responsible` plr on plr.`lose_task_id`=plt.`id`
LEFT JOIN `ph_bi`.`sys_store` ss3 on ss3.id = plr.store_id
LEFT JOIN `ph_bi`.`translations` t ON plt.duty_reasons = t.t_key AND t.`lang` = 'zh-CN'
join tmpale.tmp_ph_pno_lj_0904 t on t.pno = plt.pno
where
    1=1
    and plt.`state` in (5,6)
group by 1



;

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
    ,pi.dst_name
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
    ,pi.dst_name
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on if(pi.returned = 0, pi.pno, pi.customary_pno) = pi2.pno
left join ph_drds.lazada_order_info_d loi on loi.pno = pi2.pno
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_staging.ka_profile kp on kp.id = pi2.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi2.client_id
where
    pi.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')


;


select
    *
from ph_bi.parcel_lose_task plt
where
    plt.duty_type = 1
    and plt.updated_at > '2025-02-01'
    and plt.state = 6