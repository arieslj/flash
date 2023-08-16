SELECT
    ss.name 网点名称
    ,ss.id 网点ID
    ,ss.detail_address 网点【表情】
    ,ss.lat 网点经度
    ,ss.lng 网点经纬度
    ,sr.max_time 最晚派件时间
from ph_staging.sys_store ss
left join
    (
        select
            td.store_id
            ,max(convert_tz(td.created_at, '+00:00', '+08:00')) max_time
        from ph_staging.ticket_delivery td
        where
            td.store_id in ('PH13210A00','PH13080100')
        group by 1
    ) sr on sr.store_id = ss.id
where
    ss.id in  ('PH13210A00','PH13080100')

;

select
    *
from ph_staging.parcel_info pi
where
    pi.state not in (5,7,8,9)
    and pi.dst_store_id in ('PH13080100')
limit   100


;


        select
            pr.pno
            ,pi.client_id 客户ID
            ,pr.store_name 妥投DC
            ,pr.staff_info_id 操作人
            ,convert_tz(pr.routed_at, '+00:00', '+08:00')  操作时间
            ,ss.name 揽收网点
            ,pi.ticket_pickup_staff_info_id 揽收快递员
            ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽收时间
        from ph_staging.parcel_info pi
        left join ph_staging.parcel_route pr on pi.pno = pr.pno and pr.route_action = 'DELIVERY_CONFIRM'
        left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
        where
            pi.pno in ('P81161MZENJBU','P61231JR3CAAM','P19061JSRSUAQ','P21011KK19PAD','P61251JD8A8AS','P61201KN93RGP','P19031HFQD0AI','P61201HVBY2BB','P19061HNBK6AH','P35171G4P78BP','P61301NRZNQAT','P18181NWY3TAB','P61201M9DYWGQ','P21081N89D3AC','P61231K7JVSAQ','P61201MJPHTGD','P61181MDSQMBI','PD61181NKC5EEW','P61181NM961FI','P21081NK6Y7AI','P61271MFDTYAG','P17211J6NDPBT','P61201MR676GV','P17241NKS2AAY','P61181FXGHPCC','P19241N9ZW7BR','PD61181KV5Y5AE','P61011HWHKCDO','P61181JF5PFBL','P61181JQWAPAV','P61231MJUJBAP','P61171N0R5QAV','P33131CWU05AA','P61181K9A2QAI','P61181P47W6CF','PD61181NKCC0EW','P61161J02YYAG','P61181JCHYNBJ','P21041HE1JQAZ','P18031K6ABCCO','PD61181NKC90EW','P21081NJVBNAB','PD61011N0XJ6JQ','P21031H95UJAC','P61171MPVX2AO','P61271MZ2X1AI','P53021BBRJ0CE','P21021JZPU8AI','P18061J0KMZCB','P20071HJXF5AK','P21021HJA9QAG','P61151J6HF4AA','P61301MY14HAV','PT203121JVXS1AK','PT611721JNNV4AH','PT470521G7DT2AL','PT172821K51J3AX','PT182321KK500AJ','PT612021MBUW2GK','PT170321JRHF1BH','PT612121JT7J6AU','PT612121K5Y22AH','PT612021GYQC4AN','PT192621JEEQ2AN','PT611421JW3Y7BO','PT611921JMNA7AT','PT193021KRPR5AH','PT612321JTJT2AQ','PT800921M6WA3BK','PT611821HKUD1ET','PT17221YB7J7AG','PT612221JSYM1AH','PT201821JUKR3AP','PT611821N1B08FJ','PT611721JSB44AN','PT181521M0AD3AT','PT611721JC808AO','PT610121J8MH9DP','PT20371Y9JA2AD','PT21021WVD14AD','PT21081X3AS4AI','PT21021WU4R0AF','PT61191XER28AH','PT21021WXHN5AD','PT61031WW8X1AL','PT61181XQV48CZ','PT21131YE2W3AD','PT21121X3EE4AQ','PT61181YM734AJ','PT21111Y5994AC','PT80071WYPR4AP','PT61181X6TF0DX','PT61181YQZ07CN','PT18171YCQX9AK','PT61181YS2F1BN','PT21101XQP80AG','PT190521FCNG6BE','PT61271YJFD3AD','PT19111VEE70AA','PT61171XQD07AK','PT610821G5BF5AH','PT23031Y3900AX','P80031MPB98BE','P19161HM0EPAW','P78031NHDHBAI','P61251MW6SXAB','P19191H4BYJAK','P80111GTUYZAB','P17081JJRPXAO','P19261NPWPWAB','P20011NQK0HAK','P12181KYAQ4AF','P61171M75KGBA','P19261MD1J7AY','P19261NN61UAZ','P61181N971JFI','P61181M76X9EW','P61181MDE8TAK','P19291MKCWNAK','P21051J8FSKAB','P20351JMQBPAG','P79091JA9VDAO','P61181H1CBCEX','P19261MBJQMAB','P19261H34CPAB','P61251N9G1AAI','P61231N2WV1AE','P79101HBFUSAE','P20201FENQMAV','P19051MFFEUAZ','P07331H2781AM','P21081NQN7UAJ','P19281P7ZUAAH','P21051HWMC1AA','P20181H7XC9AZ','P61161H8VGHAL','P18101HP9VWBC','P20031GNVVVAB','P21131P2D5UAB','P61171JZK66BD','P61181JBS4AAJ','P19251K5XDEAE','P61181HWMFAAL','P61231N5PB3AK','P61161H0R0SAB','P17051MFE0GAA','P20231JMTM1AP','P61201KCTBMGF','P61201K99ACAR','P20181HT3QWAS','P61171JKEE1AV','P19241N3N3YCF','P60111CXSK5AD','P18061HJNECAI','P61201KS8E0GC','PT612521G3PD0AV','P02261J6HM0BF','P17221P82P9AJ','P20181N7Y97AZ','P180315NYQWCB')



;



select
    *
from dw_dmd.parcel_store_stage_new pssn
where
    pssn.shipped_at >= date_sub(curdate(), interval 7 day)
    and pssn.van_left_at is null
    and pssn.store_category in (8,12)


;


 select
 de.pno '运单号'
,de.src_store 揽件网点
,de.src_piece 揽收网点片区
,de.src_region 揽收网点大区
 ,de.pick_date '揽收时间'
 ,de.client_id '客户ID'
 ,pi.cod_amount/100 'cod金额'
 ,de.dst_routed_at '到仓时间'
 ,date_diff(CURRENT_DATE(),de.dst_routed_at) '在仓天数'
 ,pi.dst_name '收件人姓名'
 ,pi.dst_phone '收件人电话'
 ,sp.name '收件人省'
 ,sc.name '收件人市'
 ,sd.name '收件人乡'
 ,ss.name '目的地网点'
 ,smr.name '大区'
 ,smp.name '片区'
 ,pr.'交接次数'
 ,pr1.'改约次数'
 ,pr2.'外呼次数(10秒以上)'
 ,pr3.'外呼或来电有接通次数'
 ,if(acc.pno is not null,'被投诉',null) '是否被投诉'
 ,if(plt.pno is not null,'进入过闪速',null) '是否进入过闪速'
 ,pr4.'路由动作'
 ,convert_tz(pr4.routed_at,'+00:00','+08:00') '操作时间'
 ,pr4.staff_info_id '操作员工ID'
 ,pr4.name '操作网点'
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
ELSE '其他'
end as '包裹状态'
from dwm.dwd_ex_ph_parcel_details de
join ph_staging.parcel_info pi on de.pno=pi.pno
left join ph_bi.sys_province sp on sp.code=pi.dst_province_code
left join ph_bi.sys_city sc on sc.code=pi.dst_city_code
left join ph_bi.sys_district sd on sd.code=pi.dst_district_code
left join ph_bi.sys_store ss on ss.id=pi.dst_store_id
left join ph_bi.sys_manage_region smr on smr.id=ss.manage_region
left join ph_bi.sys_manage_piece smp on smp.id=ss.manage_piece
left join
	(select
	pr.pno
	,count(pr.pno) '交接次数'
	from ph_staging.parcel_route pr
	where pr.routed_at>=CURRENT_DATE()-interval 90 day
	and pr.route_action='DELIVERY_TICKET_CREATION_SCAN'
	group by 1)pr on pr.pno=de.pno
left join
    (select
	pr.pno
	,count(pr.pno) '改约次数'
	from ph_staging.parcel_route pr
	where pr.routed_at>=CURRENT_DATE()-interval 90 day
	and pr.route_action='DELIVERY_MARKER'
	and pr.marker_category in(9,14,70)
	group by 1)pr1 on pr1.pno=de.pno
left join
  (select
	pr.pno
	,count(pr.pno) '外呼次数(10秒以上)'
	from ph_staging.parcel_route pr
	where pr.routed_at>=CURRENT_DATE()-interval 90 day
	and pr.route_action='PHONE'
	and replace(json_extract(pr.extra_value,'$.diaboloDuration'),'\"','')>=10
	group by 1)pr2 on pr2.pno=de.pno
left join
   (select
	pr.pno
	,count(pr.pno) '外呼或来电有接通次数'
	from ph_staging.parcel_route pr
	where pr.routed_at>=CURRENT_DATE()-interval 90 day
	and pr.route_action in ('PHONE','INCOMING_CALL')
	and replace(json_extract(pr.extra_value,'$.callDuration'),'\"','')>0
	group by 1)pr3 on pr3.pno=de.pno
left join
	(select
	distinct
	acc.pno
	from ph_bi.abnormal_customer_complaint acc
	where acc.created_at>=CURRENT_DATE()-interval 90 day )acc on acc.pno=de.pno
left join
	(select
	distinct plt.pno
	from ph_bi.parcel_lose_task plt
	where plt.created_at>=CURRENT_DATE()-interval 90 day )plt on plt.pno=de.pno
left join
   (select
   pr.pno
   ,pr.staff_info_id
   ,ss.name
   ,case pr.route_action
when 'ACCEPT_PARCEL'	THEN '接件扫描'
when 'ARRIVAL_GOODS_VAN_CHECK_SCAN'	THEN '车货关联到港'
when 'ARRIVAL_WAREHOUSE_SCAN'	THEN '到件入仓扫描'
when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN'	THEN '取消到件入仓扫描'
when 'CANCEL_PARCEL'	THEN '撤销包裹'
when 'CANCEL_SHIPMENT_WAREHOUSE'	THEN '取消发件出仓'
when 'CHANGE_PARCEL_CANCEL'	THEN '修改包裹为撤销'
when 'CHANGE_PARCEL_CLOSE'	THEN '修改包裹为异常关闭'
when 'CHANGE_PARCEL_IN_TRANSIT'	THEN '修改包裹为运输中'
when 'CHANGE_PARCEL_INFO'	THEN '修改包裹信息'
when 'CHANGE_PARCEL_SIGNED'	THEN '修改包裹为签收'
when 'CLAIMS_CLOSE'	THEN '理赔关闭'
when 'CLAIMS_COMPLETE'	THEN '理赔完成'
when 'CLAIMS_CONTACT'	THEN '已联系客户'
when 'CLAIMS_TRANSFER_CS'	THEN '转交总部cs处理'
when 'CLOSE_ORDER'	THEN '关闭订单'
when 'CONTINUE_TRANSPORT'	THEN '疑难件继续配送'
when 'CREATE_WORK_ORDER'	THEN '创建工单'
when 'CUSTOMER_CHANGE_PARCEL_INFO'	THEN '客户修改包裹信息'
when 'CUSTOMER_OPERATING_RETURN'	THEN '客户操作退回寄件人'
when 'DELIVERY_CONFIRM'	THEN '确认妥投'
when 'DELIVERY_MARKER'	THEN '派件标记'
when 'DELIVERY_PICKUP_STORE_SCAN'	THEN '自提取件扫描'
when 'DELIVERY_TICKET_CREATION_SCAN'	THEN '交接扫描'
when 'DELIVERY_TRANSFER'	THEN '派件转单'
when 'DEPARTURE_GOODS_VAN_CK_SCAN'	THEN '车货关联出港'
when 'DETAIN_WAREHOUSE'	THEN '货件留仓'
when 'DIFFICULTY_FINISH_INDEMNITY'	THEN '疑难件支付赔偿'
when 'DIFFICULTY_HANDOVER'	THEN '疑难件交接'
when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE'	THEN '疑难件交接货件留仓'
when 'DIFFICULTY_RE_TRANSIT'	THEN '疑难件退回区域总部/重启运送'
when 'DIFFICULTY_RETURN'	THEN '疑难件退回寄件人'
when 'DIFFICULTY_SEAL'	THEN '集包异常'
when 'DISCARD_RETURN_BKK'	THEN '丢弃包裹的，换单后寄回BKK'
when 'DISTRIBUTION_INVENTORY'	THEN '分拨盘库'
when 'DWS_WEIGHT_IMAGE'	THEN 'DWS复秤照片'
when 'EXCHANGE_PARCEL'	THEN '换货'
when 'FAKE_CANCEL_HANDLE'	THEN '虚假撤销判责'
when 'FLASH_HOME_SCAN'	THEN 'FH交接扫描'
when 'FORCE_TAKE_PHOTO'	THEN '强制拍照路由'
when 'HAVE_HAIR_SCAN_NO_TO'	THEN '有发无到'
when 'HURRY_PARCEL'	THEN '催单'
when 'INCOMING_CALL'	THEN '来电接听'
when 'INTERRUPT_PARCEL_AND_RETURN'	THEN '中断运输并退回'
when 'INVENTORY'	THEN '盘库'
when 'LOSE_PARCEL_TEAM_OPERATION'	THEN '丢失件团队处理'
when 'MANUAL_REMARK'	THEN '添加备注'
when 'MISS_PICKUP_HANDLE'	THEN '漏包裹揽收判责'
when 'MISSING_PARCEL_SCAN'	THEN '丢失件包裹操作'
when 'NOTICE_LOST_PARTS_TEAM'	THEN '已通知丢失件团队'
when 'PARCEL_HEADLESS_CLAIMED'	THEN '无头件包裹已认领'
when 'PARCEL_HEADLESS_PRINTED'	THEN '无头件包裹已打单'
when 'PENDING_RETURN'	THEN '待退件'
when 'PHONE'	THEN '电话联系'
when 'PICK_UP_STORE'	THEN '待自提取件'
when 'PICKUP_RETURN_RECEIPT'	THEN '签回单揽收'
when 'PRINTING'	THEN '打印面单'
when 'QAQC_OPERATION'	THEN 'QAQC判责'
when 'RECEIVE_WAREHOUSE_SCAN'	THEN '收件入仓'
when 'RECEIVED'	THEN '已揽收,初始化动作，实际情况并没有作用'
when 'REFUND_CONFIRM'	THEN '退件妥投'
when 'REPAIRED'	THEN '上报问题修复路由'
when 'REPLACE_PNO'	THEN '换单'
when 'REPLY_WORK_ORDER'	THEN '回复工单'
when 'REVISION_TIME'	THEN '改约时间'
when 'SEAL'	THEN '集包'
when 'SEAL_NUMBER_CHANGE'	THEN '集包件数变化'
when 'SHIPMENT_WAREHOUSE_SCAN'	THEN '发件出仓扫描'
when 'SORTER_WEIGHT_IMAGE'	THEN '分拣机复秤照片'
when 'SORTING_SCAN'	THEN '分拣扫描'
when 'STAFF_INFO_UPDATE_WEIGHT'	THEN '快递员修改重量'
when 'STORE_KEEPER_UPDATE_WEIGHT'	THEN '仓管员复秤'
when 'STORE_SORTER_UPDATE_WEIGHT'	THEN '分拣机复秤'
when 'SYSTEM_AUTO_RETURN'	THEN '系统自动退件'
when 'TAKE_PHOTO'	THEN '异常打单拍照'
when 'THIRD_EXPRESS_ROUTE'	THEN '第三方公司路由'
when 'THIRD_PARTY_REASON_DETAIN'	THEN '第三方原因滞留'
when 'TICKET_WEIGHT_IMAGE'	THEN '揽收称重照片'
when 'TRANSFER_LOST_PARTS_TEAM'	THEN '已转交丢失件团队'
when 'TRANSFER_QAQC'	THEN '转交QAQC处理'
when 'UNSEAL'	THEN '拆包'
when 'UNSEAL_NOT_SCANNED'	THEN '集包已拆包，本包裹未被扫描'
when 'VEHICLE_ACCIDENT_REG'	THEN '车辆车祸登记'
when 'VEHICLE_ACCIDENT_REGISTRATION'	THEN '车辆车祸登记'
when 'VEHICLE_WET_DAMAGE_REG'	THEN '车辆湿损登记'
when 'VEHICLE_WET_DAMAGE_REGISTRATION'	THEN '车辆湿损登记'
else pr.route_action
end '路由动作'
,pr.routed_at
   ,row_number()over(partition by pr.pno order by pr.routed_at desc) rank
   from ph_staging.parcel_route pr
   left join ph_bi.sys_store ss on ss.id=pr.store_id
   where pr.routed_at>=CURRENT_DATE()-interval 60 day
   and pr.route_action in ('RECEIVED','RECEIVE_WAREHOUSE_SCAN','SORTING_SCAN','DELIVERY_TICKET_CREATION_SCAN',
                                           'ARRIVAL_WAREHOUSE_SCAN','SHIPMENT_WAREHOUSE_SCAN','DETAIN_WAREHOUSE','DELIVERY_CONFIRM',
                                           'DIFFICULTY_HANDOVER','DELIVERY_MARKER','REPLACE_PNO','SEAL','UNSEAL','PARCEL_HEADLESS_PRINTED',
                                           'STAFF_INFO_UPDATE_WEIGHT','STORE_KEEPER_UPDATE_WEIGHT','STORE_SORTER_UPDATE_WEIGHT',
                                           'DISCARD_RETURN_BKK','DELIVERY_TRANSFER','PICKUP_RETURN_RECEIPT','FLASH_HOME_SCAN',
                                           'ARRIVAL_WAREHOUSE_SCAN','SORTING_SCAN', 'INVENTORY'))pr4 on pr4.pno=de.pno and pr4.rank=1
where de.pick_date>='2022-07-01'
and pi.state not in (5,7,8,9)
and de.cod_enabled='YES'
and date_diff(CURRENT_DATE(),de.dst_routed_at)>=3

 ;


with t as
(
    select
        pr.pno
        ,pr.routed_at
    from ph_staging.parcel_route pr
    where
        pr.route_action = 'DELAY_RETURN'
        and pr.routed_at > '2023-06-01 16:00:00'
)
select
    pr2.pno
    ,pr2.store_name 网点
    ,convert_tz(pr2.routed_at, '+00:00', '+08:00') 留仓时间
    ,if(a2.pno is not null , '是', '否') 次日之后是否有派件交接
from ph_staging.parcel_route pr2
join t t1 on t1.pno = pr2.pno and date(convert_tz(t1.routed_at, '+00:00', '+08:00')) = date(convert_tz(pr2.routed_at, '+00:00', '+08:00'))
left join
    (
        select
            pr3.pno
        from ph_staging.parcel_route pr3
        join t t2 on t2.pno = pr3.pno
        where
            pr3.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            and pr3.routed_at > date_sub(date(convert_tz(t2.routed_at, '+00:00', '+08:00')), interval 8 hour )
    ) a2 on a2.pno = pr2.pno
where
    pr2.route_action = 'DETAIN_WAREHOUSE'
    and pr2.routed_at > '2023-06-01 16:00:00'

;


select
    pi.pno
from ph_staging.parcel_info pi
join ph_bi.parcel_lose_task plt on plt.pno = pi.pno and plt.state = 6
left join dwm.dwd_ex_ph_parcel_details de on de.pno = pi.pno
where
    pi.state not in (5,7,8,9)
    and pi.dst_store_id = 'PH19040F05'
    and de.last_store_id = 'PH19040F05'
group by 1
