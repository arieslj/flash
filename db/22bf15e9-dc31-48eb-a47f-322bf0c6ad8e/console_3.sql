select
    ph.print_state
from fle_staging.parcel_headless ph
where
    ph.state != 3
group by 1
;


with ss as
(
    select
        ss.id
        ,ss.name
        ,ss.district_code
        ,sd.en_name district_name
        ,ss.city_code
        ,sc.en_name city_name
        ,ss.province_code
        ,sp.en_name province_name
        ,ss.postal_code
    from fle_staging.sys_store ss
    left join fle_staging.sys_province sp on sp.code = ss.province_code
    left join fle_staging.sys_city sc on sc.code = ss.city_code
    left join fle_staging.sys_district sd on sd.code = ss.district_code
)
select
    pi.pno
    ,case t.type
        when 'bb' then '本本'
        when 'kj' then '跨境'
    end 类型
    ,ss1.id 网点编号
    ,ss1.name 揽收网点名称
    ,ss1.province_code 揽收网点省code
    ,ss1.province_name 揽收网点省
    ,ss1.city_code 揽收网点市code
    ,ss1.city_name 揽收网点市
    ,ss1.district_code 揽收网点乡code
    ,ss1.district_name 揽收网点乡
    ,ss1.postal_code 揽收网点邮编
    ,oi.dst_province_code 订单目的地省code
    ,sp.en_name 订单目的地省
    ,ss2.province_code 妥投网点所在省code
    ,ss2.province_name 妥投网点所在省
    ,if(ss2.province_code = oi.dst_province_code, '是', '否') 省份是否相同
    ,oi.dst_city_code 订单目的地市code
    ,sc.en_name 订单目的地市
    ,ss2.city_code 妥投网点所在市code
    ,ss2.city_name 妥投网点所在市
    ,if(ss2.city_code = oi.dst_city_code, '是', '否') 市是否相同
    ,oi.dst_district_code 订单目的地乡code
    ,sd.en_name 订单目的地乡
    ,ss2.district_code 妥投网点所在乡code
    ,ss2.district_name 妥投网点所在乡
    ,if(ss2.district_code = oi.dst_district_code, '是', '否') 乡是否相同
    ,oi.dst_postal_code 订单目的地邮编
    ,ss2.postal_code 妥投网点邮编
    ,if(ss2.postal_code = oi.dst_postal_code, '是', '否') 邮编是否相同
    ,pi.upcountry '1=偏远地区'
    ,pi.upcountry_amount '偏远地区费（分）'
    ,if(pi.dst_province_code in ('TH01','TH02','TH03','TH04'), 1, 0) 是否BKK
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_lj_0426 t on pi.pno = t.pno
left join fle_staging.order_info oi on oi.pno = t.pno
left join ss ss1 on ss1.id = pi.ticket_pickup_store_id
left join fle_staging.sys_province sp on sp.code = oi.dst_province_code
left join fle_staging.sys_city sc on sc.code = oi.dst_city_code
left join fle_staging.sys_district sd on sd.code = oi.dst_district_code
left join ss ss2 on ss2.id = pi.ticket_delivery_store_id


;
select
    pct.created_at 任务生成时间
    ,pct.parcel_created_at 包裹揽收时间
    -- ,concat(TIMESTAMPDIFF(second,pct.created_at,pct.updated_at)/3600,'H',timestampdiff(second,pct.created_at,pct.updated_at)/60,'M') 处理时长
    ,concat('SSLP00',pct.id) 任务ID
    ,pct.pno 运单号
    ,pi.returned_pno 退货运单号
    ,case pct.self_claim
    when 1 then '是'
    when 0 then '否'
    end 自主理赔
    ,case pct.vip_enable
    when 0 then '普通客户'
    when 1 then 'KAM客户'
    end 客户类型
   /* ,case pct.vehicle_abnormal_type

    end 车辆异常
    , 理赔对象*/
    ,pct.client_id 客户ID
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) cogs
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
    end 问题来源渠道
    ,plt.duty_reasons
    ,t.t_key
    ,t.t_value QAQC判责原因
    ,pi.exhibition_weight 重量
    ,concat_ws('*',pi.exhibition_length,pi.exhibition_width,pi.exhibition_height) 尺寸
   /* , 是否符合水果理赔条件
    , 不符合理赔条件原因
    ,case pct.state

    end 状态*/
    ,pct.area 区域
    ,hsi.name 处理人
    ,pct.updated_at 处理时间
   -- , 理赔完成时间
    ,if(pcn.neg_type IN (5,6,7),json_extract(pcn.neg_result,'$.money'),null) 客户申请理赔金额
    ,if(pcn.neg_type IN (1,3,5,6,7),json_extract(pcn.neg_result,'$.money'),null) 理赔金额
  --  , 理赔途径
    ,pco1.created_at 客户第一次上传资料时间
    ,pco2.created_at 客户最后上传资料时间
    ,pco3.created_at 客服第一次处理时间
    ,pco4.created_at 客服最后处理时间
  --  , 驳回次数
    ,if(pi.state=5,round(TIMESTAMPDIFF(second,pi.created_at,pi.finished_at)/86400,1),round(TIMESTAMPDIFF(second,convert_tz(pi.created_at,'+00:00','+07:00'),pct.created_at)/86400,1))运输天数
    ,case pi.freight_insure_enabled
    when 0 then '否'
    when 1 then '是'
    end 是否购买运费险
from bi_pro.parcel_claim_task pct

left join
(-- 第一次上传资料
    select
    pco.*
    from
    (
    select
        pco.task_id
        ,pco.created_at
        ,row_number()over(partition by pco.task_id order by pco.created_at) rn
    from bi_pro.parcel_cs_operation_log pco
    where pco.action=22
    )pco where pco.rn=1
)pco1
on pco1.task_id=pct.id

left join
(-- 最后一次上传资料
    select
    pco.*
    from
    (
    select
        pco.task_id
        ,pco.created_at
        ,row_number()over(partition by pco.task_id order by pco.created_at desc) rn
    from bi_pro.parcel_cs_operation_log pco
    where pco.action=22
    )pco where pco.rn=1
)pco2
on pco2.task_id=pct.id
left join
(-- 客服第一次
    select
    pco.*
    from
    (
    select
        pco.task_id
        ,pco.created_at
        ,row_number()over(partition by pco.task_id order by pco.created_at) rn
    from bi_pro.parcel_cs_operation_log pco
    where pco.action=21
    )pco where pco.rn=1
)pco3
on pco3.task_id=pct.id

left join
(-- 客服最后一次
    select
    pco.*
    from
    (
    select
        pco.task_id
        ,pco.created_at
        ,row_number()over(partition by pco.task_id order by pco.created_at desc) rn
    from bi_pro.parcel_cs_operation_log pco
    where pco.action=21
    )pco where pco.rn=1
)pco4
on pco4.task_id=pct.id

left join  bi_pro.parcel_claim_negotiation pcn
on pcn.task_id =pct.id

left join dwm.tmp_ex_big_clients_id_detail bc
on pct.client_id=bc.client_id

left join fle_staging.order_info oi
on pct.pno=oi.pno

left join bi_pro.parcel_lose_task plt
on plt.id=pct.lose_task_id

left join bi_pro.translations t
on plt.duty_reasons=t.t_key
and t.lang ='zh-CN'

left join fle_staging.parcel_info pi
on pct.pno=pi.pno

left join bi_pro.hr_staff_info hsi
on hsi.staff_info_id=pct.operator_id

where pct.created_at>='2023-03-01'
-- and pct.created_at<'2023-04-01'
and pct.pno='TH011840B1YJ1A0'
group by 3

;







select
    t.运单号
    ,case pct.state
        when 1 then '待协商'
        when 2 then '协商不一致，待重新协商'
        when 3 then '待财务核实'
        when 4 then '核实通过，待财务支付'
        when 5 then '财务驳回'
        when 6 then '理赔完成'
        when 7 then '理赔终止'
        when 8 then '异常关闭'
        when 9 then '待协商（搁置）'
        when 10 then '等待再次联系'
    end 状态
    ,replace(json_extract(a.neg_result,'$.money'),'"','') 理赔金额
from bi_pro.parcel_claim_task pct
join tmpale.tmp_th_pno_lj_0508 t on t.运单号 = pct.pno
left join
    (
        select
            pct.id
        #     ,case pct.state
        #         when 1 then '待协商'
        #         when 2 then '协商不一致，待重新协商'
        #         when 3 then '待财务核实'
        #         when 4 then '核实通过，待财务支付'
        #         when 5 then '财务驳回'
        #         when 6 then '理赔完成'
        #         when 7 then '理赔终止'
        #         when 8 then '异常关闭'
        #         when 9 then' 待协商（搁置）'
        #         when 10 then '等待再次联系'
        #     end 状态
            ,pct.state
            ,pcn.neg_result
            ,row_number() over (partition by pcn.task_id order by pcn.created_at desc ) rk
        from bi_pro.parcel_claim_task pct
        join tmpale.tmp_th_pno_lj_0508 t on t.运单号 = pct.pno
        left join bi_pro.parcel_claim_negotiation pcn on pcn.task_id = pct.id
        where
            pct.state = 6
    ) a on pct.id = a.id and a.rk = 1

;



select
    *
from
    (
        select
            plt.pno
            ,plt.updated_at
        from bi_pro.parcel_lose_task plt
        join tmpale.tmp_th_pno_lj_0508 t on t.pno = plt.pno
        where
            plt.state = 6
        group by 1,2
    ) a
left join
    (
        select
            *
        from phstag
    )



;

select  * from tmpale.d_th_excelToJSON
;

select
    pi.pno
    ,pssn.first_valid_routed_at 目的地网点的第一次有效路由时间
    ,pssn.last_valid_routed_at 目的地网点的最后一次有效路由时间
    ,datediff(curdate(), pssn.first_valid_routed_at) 在仓天数
from fle_staging.parcel_info pi
left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = pi.pno and pi.dst_store_id = pssn.store_id and pssn.valid_store_order is not null
where
    pi.state not in (5,7,8,9)
    and pssn.first_valid_routed_at < date_sub(curdate(), interval  2 day )


;




select
    plt.pno
    ,pi.customary_pno 原单号
    ,ss.name  上报网点
    ,plt.parcel_created_at 揽收时间
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
        end 最后有效操作路由
    ,plt.last_valid_staff_info_id 最后有效路由操作人ID
    ,hjt.job_name 最后有效路由操作人职位
    ,pi.cod_amount/100  COD金额
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 包裹尺寸
    ,pssn.arrived_at ‘到件入仓时间（目的地网点）’
    ,plt.created_at 闪速任务生成时间
from bi_pro.parcel_lose_task plt
left join fle_staging.parcel_info pi on pi.pno = plt.pno
left join fle_staging.customer_diff_ticket cdt on cdt.id = plt.source_id
left join fle_staging.diff_info di on di.id = cdt.diff_info_id
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = plt.last_valid_staff_info_id
left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
left join fle_staging.sys_store ss on ss.id = di.store_id
left join fle_staging.sys_store ss2 on ss2.id = plt.last_valid_store_id
left join dw_dmd.parcel_store_stage_new pssn on pssn.pno = plt.pno and pssn.store_id = pi.dst_store_id
where
    plt.source = 1
    and plt.state not in (5,6)



;


select
    pi.pno
    ,case ppd.parcel_problem_type_category
        when 1 then '问题件'
        when 2 then '留仓件'
    end 类型
    ,date(convert_tz(ppd.created_at, '+00:00', '+07:00')) 标记时间
    ,if(dt.双重预警 = 'Alert', '是', '否') 当日是否爆仓
from fle_staging.parcel_info pi
left join  fle_staging.parcel_problem_detail ppd on ppd.pno = pi.pno
left join dwm.dwd_th_network_spill_detl_rd dt on dt.统计日期 = date(convert_tz(ppd.created_at, '+00:00', '+07:00')) and dt.网点ID = ppd.store_id
where
    hour(convert_tz(ppd.created_at, '+00:00', '+07:00')) < 4
    and pi.created_at > '2023-03-31 17:00:00'
    and pi.created_at < '2023-04-30 17:00:00'


;


with t as
(
    select
        di.*
    from
        (
            select
                di.pno
                ,di.store_id
                ,di.created_at
                ,date(convert_tz(di.created_at, '+00:00', '+07:00')) creat_date
                ,row_number() over (partition by di.pno order by di.created_at) rk
            from fle_staging.diff_info di
            where
                di.diff_marker_category in (31,79)  -- 分错网点，地址錯誤
                and di.created_at >= '2023-03-31 17:00:00'
                and di.created_at < '2023-04-30 17:00:00'
        ) di
    where
        di.rk = 1
)
, tdm as
(
    select
        a.*
    from
        (
              select
                td.pno
                ,tdm.created_at
                ,td.staff_info_id
                ,td.store_id
                ,t.creat_date
                ,row_number() over (partition by td.pno order by tdm.created_at desc ) rk
            from fle_staging.ticket_delivery_marker tdm
            join fle_staging.ticket_delivery td on td.id = tdm.delivery_id
            join t on t.pno = td.pno and t.store_id = td.store_id
            where
                date(convert_tz(tdm.created_at, '+00:00', '+07:00')) = t.creat_date
                and tdm.created_at < t.created_at
                and tdm.marker_id in (31,79)
        ) a
    where
        a.rk = 1
)
, pho1 as
(
    select
        a.pno
        ,a.routed_at
        ,a.cal
        ,a.dia
        ,row_number() over (partition by a.pno order by a.cal desc ) rk1
        ,row_number() over (partition by a.pno order by a.dia desc ) rk2
        ,sum(a.cal) over (partition by a.pno) cal_total
    from
        (
            select
                pr2.pno
                ,pr2.routed_at
                ,cast(json_extract(pr2.extra_value, '$.callDuration') as int) cal
                ,cast(json_extract(pr2.extra_value, '$.diaboloDuration') as int) dia
            from rot_pro.parcel_route pr2
            join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pr2.staff_info_id and hsi.job_title in (13,110,1000)
            join tdm t2 on t2.pno = pr2.pno and t2.store_id = pr2.store_id
            where
                pr2.route_action = 'PHONE'
                and date(convert_tz(pr2.routed_at, '+00:00', '+07:00')) = t2.creat_date
                and pr2.routed_at < t2.created_at
        ) a
)
, pho2 as
(
    select
        a.pno
        ,a.routed_at
        ,a.cal
        ,a.dia
        ,row_number() over (partition by a.pno order by a.cal desc ) rk1
        ,row_number() over (partition by a.pno order by a.dia desc ) rk2
        ,sum(a.cal) over (partition by a.pno) cal_total
    from
        (
            select
                pr2.pno
                ,pr2.routed_at
                ,cast(json_extract(pr2.extra_value, '$.callDuration') as int) cal
                ,cast(json_extract(pr2.extra_value, '$.diaboloDuration') as int) dia
            from rot_pro.parcel_route pr2
            join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pr2.staff_info_id and hsi.job_title in (37)
            join tdm t2 on t2.pno = pr2.pno and t2.store_id = pr2.store_id
            where
                pr2.route_action = 'PHONE'
                and date(convert_tz(pr2.routed_at, '+00:00', '+07:00')) = t2.creat_date
                and pr2.routed_at < t2.created_at
        ) a
)
select
    pi.pno
    ,pi.client_id
    ,if(scan.pno is not  null, '是', '否') 上报错分前是否交接扫描
    ,if(ppd.pno is not null , '是', '否') 上报错分前是否留仓或提交其它问题件
    ,case  ppd.diff_marker_category
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
    end '上报错分前留仓/问题件原因'
    ,t2.staff_info_id '快递员工号'
    ,if(t2.pno is not null, '是', '否' ) '快递员是否标记“分错网点-地址错误”'
    ,if(coalesce(p1.pno, p2.pno) is not null, '是', '否' ) 快递员标记前是否联系收件人
    ,coalesce(p1.dia, p2.dia) 快递员联系收件人响铃时长
    ,coalesce(p1.cal, p2.cal) 快递员联系收件人通话时长
    ,if(coalesce(p3.pno, p4.pno) is not null, '是', '否' ) '仓管员提交“分错网点-地址错误”前是否联系收件人'
    ,coalesce(p3.dia, p4.dia) 仓管员联系收件人响铃时长
    ,coalesce(p3.cal, p4.cal) 仓管员联系收件人通话时长
    ,if(am.pno is null, '否', '是' ) '是否产生“虚假错分”处罚'
    ,case am.state
        when 1 then '处罚'
        when 2 then '未审核'
        when 3 then '无需追责'
    end 处罚审核状态
    ,if(am.isdel = 1, '已删除', '未删除') 处罚删除状态
    ,case
        when am.state = 1 and am.isappeal = 1 then '未申诉'
        when am.state = 1 and am.isappeal > 1 then '已申诉'
    else null
    end 处罚申诉状态
from fle_staging.parcel_info pi
join t on t.pno = pi.pno
left join
    (
        select
            pr.pno
            ,pr.store_id
        from rot_pro.parcel_route pr
        join t on t.pno = pr.pno and t.store_id = pr.store_id
        where
            pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr.routed_at < t.created_at
        group by 1,2
    ) scan on scan.pno = t.pno and scan.store_id = t.store_id
left join
    (
        select
            ppd.pno
            ,ppd.diff_marker_category
            ,ppd.staff_info_id
            ,ppd.store_id
            ,row_number() over (partition by ppd.pno order by ppd.created_at desc) rk
        from fle_staging.parcel_problem_detail ppd
        join t on t.pno = ppd.pno and t.store_id = ppd.store_id
        where
            ppd.created_at < t.created_at
    ) ppd on ppd.store_id = t.store_id and ppd.pno = t.pno
left join tdm t2 on t2.pno = t.pno
left join pho1 p1 on p1.pno = t.pno and p1.cal_total > 0 and p1.rk1 = 1
left join pho1 p2 on p2.pno = t.pno and p2.cal_total = 0 and p2.rk2 = 1
left join pho2 p3 on p3.pno = t.pno and p3.cal_total > 0 and p3.rk1 = 1
left join pho2 p4 on p4.pno = t.pno and p4.cal_total = 0 and p4.rk2 = 1
left join bi_pro.abnormal_message am on am.pno = t.pno and am.punish_category = '53'




；

select
    pr.pno
    ,pr.routed_at
from rot_pro.parcel_route pr
join bi_pro.hr_staff_info hsi on pr.staff_info_id = hsi.staff_info_id and hsi.job_title = 37
where
    pr.route_action = 'PHONE'
    and pr.routed_at > '2023-05-10'