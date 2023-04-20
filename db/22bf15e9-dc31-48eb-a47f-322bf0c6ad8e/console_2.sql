# select
#     plt.pno
#     ,case pi.state
#         when 1 then '已揽收'
#         when 2 then '运输中'
#         when 3 then '派送中'
#         when 4 then '已滞留'
#         when 5 then '已签收'
#         when 6 then '疑难件处理中'
#         when 7 then '已退件'
#         when 8 then '异常关闭'
#         when 9 then '已撤销'
#     end as 包裹状态
#     ,convert_tz(pi.created_at, '+00:00', '+07:00') 揽收时间
# from bi_pro.parcel_lose_task plt
# left join fle_staging.parcel_info pi on plt.pno = pi.pno
# where
#     plt.state = 6
#     and plt.duty_result = 1
#     and pi.state not in (5,7,8,9)
#     and pi.discard_enabled = 1
# group by 1;

select
    pi.pno
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
    end as 包裹状态
    ,case pd.last_route_action
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
    end as 最后一条路由
from fle_staging.parcel_info pi
# join tmpale.tmp_th_pno_0316 t on t.pno = pi.pno
left join bi_pro.parcel_detail pd on pd.pno = pi.pno
where
    pi.pno in ('TH01043PNDWZ1B', 'TH01273UK0EU8D', 'TH04033PW36Y7A1', 'TH04033RZ7668A1', 'TH10033SAVRJ7K', 'TH10033SUC0X2K', 'TH10033TXAD56K', 'TH10033U71897B', 'TH10033UFG3N5K', 'TH20083HC5138B', 'TH24103N8JDW1B', 'TH67023QZ3T32C', 'THT01052B5HB8Z', 'THT01052CNZY9Z', 'THT013413GF97Z', 'THT04032CC0K2Z', 'THT05062FRFC5Z', 'THT67012B7QC9Z', 'THT67012BSNV5Z', 'THT67012D6ZS7Z', 'TH10033U4XZ40A', 'TH20083UK3EZ5C', 'TH20073VC6FB0B', 'TH04033QUZ5V4A1', 'TH04073PWE6P8K', 'TH20073RSMND0D', 'TH04013GY3C64I', 'TH20043V98EG4B', 'TH20073JYJBK0B', 'THT650120NF71Z', 'TH68043RH64Y2F', 'THT56107V97H3Z', 'TH10033U2S8P9P', 'TH67013QENWT9G', 'THT24011NRU87Z', 'TH33023BBP1E3C', 'TH27013TZ6TA5K', 'TH75103W3HT99C', 'TH01213Q1MTZ4A', 'TH21013VDNK97F', 'TH67013R9Y5R7H', 'TH20073EDGWN5B', 'TH01392WH3Y51B', 'THT15011KGTN6Z', 'TH01403RBZ4R0B0', 'THT20047PEQV5Z', 'TH04073PGWAK2A', 'TH04073KDUAG8K', 'TH10113V8QYG1A', 'TH68043RC3SC6F', 'TH19033UZXT74E', 'TH67013SBFDW1E', 'TH24033B29S10A', 'TH10113VE2B37B', 'TH01053VJQJW6B', 'TH04033JM5CD0A1', 'THT71057SC549Z', 'TH16013MVTPU0L', 'TH04073RKWXH4K-3', 'TH67013S01764H', 'TH21063UYU0U8A', 'TH67013RTA7W9G', 'TH68043S5REX1F', 'THT66021EQRK7Z', 'TH01373V58QS1C', 'TH63083SYPJ90B', 'TH10043VBWR22C', 'TH04073MWHYG9J', 'TH20083S5PKJ5A', 'TH20043VEAQT1E', 'TH67033V05572F', 'THT05062HBHQ8Z', 'TH70043V92E25K', 'TH66023HTTY82C', 'TH04033RDGXM9A1', 'THT0131BVKG9Z', 'THT670126BE69Z', 'TH20083UZXEQ8B', 'TH15013QRRZQ1O', 'TH20073K2ZRE7A', 'TH01403UU4SC8B0', 'TH01293BGQRC4A', 'THT04037PNHT5Z', 'THT1501148ZE3Z', 'THT24021P92A8Z', 'TH44113TG15V3B', 'TH01303VBEWY7A', 'TH04033QHGVW9A1', 'TH01283S8VQT3B1', 'TH67023H02DF9C', 'TH48013VEKGV1I', 'TH67013RJVPA6G', 'TH01203T5GA33B', 'TH67013R20E90G', 'TH24113MFMC47E', 'TH04063T1FT27C', 'TH24113MKGAC4C', 'TH20013NXYCJ2F', 'TH01403TSSVG6B0', 'TH67013S6V0Q7H', 'TH01373TXWYE9B', 'TH68043RPYAK0F', 'TH67033V9BEA2D', 'TH20073PG9TU9C', 'TH67013N36E68G', 'TH66023TKXTG3C', 'TH01203N984F1C', 'TH47133SX04K8I', 'TH70083PYRGK4B', 'TH20053TS9VJ3B', 'TH22043B4DTK7D', 'THT20047XU831Z', 'TH10033VEZ3P2E', 'TH20043V84MX7A', 'TH01393V87RF4E', 'TH67013RSN591H', 'TH01393HRZWK9F', 'TH26073U6VA98D', 'TH67013RVEBQ8G', 'TH04033TF7D09A1', 'TH20043HCS5Z3B1', 'TH01153NH7921A', 'THT24011M7TK4Z', 'TH61023TVVA45C', 'TH67013RMVS53G', 'TH670132JD7Q7E', 'TH67013RF6KH8G', 'TH05033TPS9X9C', 'TH37013VZ99E1A', 'TH68043RB4GT6F', 'TH32013CAU8M7A', 'TH61083B18GD8H', 'TH68043RTRX38F', 'TH71033UVTUJ9M', 'TH68043REJAX8F', 'TH67033R54H76F', 'TH67033EPWJ62A', 'TH11013R98463A', 'TH01053VA3JN1B', 'TH01303VESAU3C', 'TH02063J4EF95A0', 'TH01233S2KZ84E', 'LEXDO0057480603', 'TH01473TB4BH5B', 'TH67023R47AN0A', 'TH20073J9STN5E0', 'TH01053J3CGZ0C', 'TH01413VJ2J70B', 'TH70033UTT9C4D', 'TH20043DJX794A', 'TH20043RYW746H', 'SSLT730005611450', 'TH20043DN7JD3C', 'TH20043UU8DM1A', 'TH67013RNH7U2H', 'TH03043VCWQZ9H', 'TH01403RME2H7B0', 'TH01473UYWWS3A', 'TH20043UG13X3D', 'TH04033SA8UM9A1', 'TH01413VCJ0B1B', 'TH01403RCG2Z8B0', 'TH01273TEMWW7D', 'TH01503RY1FM6B0', 'TH64013HS07V7L', 'THT20047RMPP8Z', 'TH26073UFH341D', 'THT05032JPU55Z', 'TH20073JUV2C1B', 'TH67013RVCHB5G', 'TH24023VBEX45H', 'TH67013TBU433G', 'TH67013SWKQ56G', 'TH02023TETZ56D', 'THT21017R76C8Z', 'TH67013RTBG03G', 'TH20073RWG952E', 'THT54111Y05S5Z', 'TH01373V3N4T2B', 'TH67013RWV669H', 'TH01203RGB9T4B', 'THT20047RFJA9Z', 'TH64013E35UV5N', 'TH05063UAA8V7D', 'TH03043VDRPD3H', 'TH67013RH96T3G', 'TH04033TQE5B2A0', 'TH68043REV5B2F', 'TH15013QS6KP7O', 'TH67023RN22C5B', 'TH20083VF0UN0B', 'TH09013RNABW5D', 'TH02063UA32D7A', 'TH01213TPZH03A', 'TH68043RMVUJ0F', 'TH33053UWG5Q1C', 'THT0403KYNR5Z', 'TH02063T0QV55A', 'TH20043VEBBY8A', 'TH67013QXE7A7H', 'THT030122HJK2Z', 'TH10113V4QZ57B', 'TH63053KMKF75J', 'THT21012462Z5Z', 'TH67013SK64G8E', 'TH65013TY1KY1H', 'TH01073TUT8A9A', 'TH70083R9YWY5C', 'FLACB02017460937', 'TH01473UFV758B', 'TH10113UVYV98B', 'TH56023BQBZM8H', 'TH67013RH7VC8H', 'TH01213SJDJG6A', 'TH66023KG2X04C', 'TH21013V23S27C', 'TH01373JKRJ54B', 'THT56027XXEN0Z', 'TH66023J06CX6C', 'TH24023N0S583F', 'TH68043R62UJ9F', 'TH24043V2QUQ7D', 'TH67013SU38Q9G', 'TH67013RWBXK7G', 'TH68043RFPHE5F', 'TH65013MKY0M5G', 'TH10033VEA2Z4I', 'TH04033S62PK5A0', 'TH10033VDZBU2E', 'TH67013QQUSD5G', 'TH10033UAHNR6P', 'TH013932659B4G', 'TH01163UWSH23A0', 'TH01183VDZTS6A0', 'THT03022HC7C4Z', 'TH21013UUG723F', 'TH05033VB0VS9C', 'TH68043RMT4M6F', 'TH01373V3NEC0B', 'TH67013RVGR36G', 'TH55033K9VAG8B', 'TH01423UPVN92A', 'THT01407R38E5Z', 'TH10033V3HKC0Q', 'TH01473VBCC06C', 'TH65013SKH3W4H', 'TH67013Q87KT5H', 'TH01183RVDKX7A1', 'TH66023KJ79Z8C', 'TH67023HRZHJ8C', 'TH02043T5RW63O', 'TH10113VASDZ8B', 'TH05033U23QE7B', 'TH21063Q8GYK3A', 'TH05033USZTC8I', 'TH67013RPBH03G', 'TH20073JSVJK6B', 'LEXPU0180148516', 'TH67013RSGT12H', 'TH01393VJFQZ4B', 'TH47013U4XUC1C', 'THT67022AU899Z', 'TH67013RV5G61G', 'THT21062BHSV7Z', 'TH05033UH8NQ3G', 'SSLT730006233687', 'TH26073UZ34E7A', 'THT01407QXC36Z', 'TH74043V9FJX5C', 'TH10043VGDEP0E', 'TH12033VA3MD1B', 'TH20073HW5T27B', 'TH01273GJFNC3D', 'TH67013K54Q24B', 'TH05033UQWPU5J', 'TH02063FA2E71A-1', 'TH04033RMX396A1', 'TH20043CPU6J9B0', 'TH20083U2QAV3B', 'TH13133TYY7Q9D', 'TH20043V95CS6G', 'THT21017U94Y0Z', 'TH40053NCX632D', 'TH02063CAA6C8A', 'TH13023RM3PV2A-1', 'THT21062BDX08Z', 'THT01407RXMJ4Z', 'TH20073JJQWU7B', 'TH01373VNA8B8B', 'TH20083W61SP1D', 'TH01423U1JGS6A', 'TH24013NB1705L', 'TH20043V3D3C0D', 'TH24023VBBN50H', 'TH10113UXGYB2D', 'TH68043U88W11E', 'TH67013P6RCW6E', 'TH10033R2TZE6E', 'TH15063SJVGM1H', 'TH68043R5JS62F', 'TH10033V87PV6A', 'THT20047RDFW5Z', 'TH62013TA49W5A', 'TH10033UUGHX4B', 'THT21017R6VD6Z', 'TH20043DWPDU5C', 'TH01373V3R8A4C', 'TH15063HW76U7J', 'TH66013U1W973H', 'THT66021EHQ63Z', 'TH20043U2DVU4C', 'TH01473U1G967B', 'TH65023Q1S356B', 'TH20073HTQW31A', 'TH67013RTBKY5G', 'TH70083TSXUF4B', 'TH01473UWFFM3B', 'TH20073RWG991E', 'TH01143S2H0A2E', 'TH65053Q78UG5E', 'TH04073S5UH49C', 'TH01303VE0S29A', 'TH01373UB3D82C', 'TH60033PV8G64B', 'TH04063MQU3G4A1', 'THT20087P7NW5Z', 'TH01303SDDTP2C', 'TH10033UHG168B', 'TH26073UY1ZM1A', 'SSLT730006651767', 'TH01303EJW0H8A', 'TH66023M0BQ69C', 'THT20042G8989Z', 'TH20043UQCNT9D', 'TH67033SWMKH7C', '7110015818354', 'TH01373E7VJ83A', 'TH01403UUJGZ3B0', 'TH67023U39PJ7C', 'TH01473VJW806A', 'TH10113V5SA56B', 'THT20042HTNU4Z', 'TH38013CVWVA6A0', 'TH16033BJJFT0C', 'TH67033QAHVX6F', 'TH68043RGX702F', 'TH10113UQSBM7B', 'TH01423TNP7F6A', 'TH26063BFXQ89A', 'TH05063VDKN39F', 'TH04063V87RJ2E', 'TH04033V8HM87A1')

;

select
    pct.pno
    ,case pct.state
        when 6 then '理赔完成'
        when 7 then '理赔终止'
    end 理赔状态
    ,plt.id
    ,case plt.`source`
        when 1 then 'a-问题件-丢失'
        when 2 then 'b-记录本-丢失'
        when 3 then 'c-包裹状态未更新'
        when 4 then 'd-问题件-破损/短少'
        when 5 then 'e-记录本-索赔-丢失'
        when 6 then 'f-记录本-索赔-破损/短少'
        when 7 then 'g-记录本-索赔-其他'
        when 8 then 'h-包裹状态未更新-ipc计数'
        when 9 then 'i-问题件-外包装破损险'
        when 10 then 'j-问题记录本-外包装破损险'
        when 11 then 'k-超时效包裹'
        when 12 then 'l-高度疑似丢失'
    end '闪速认定问题来源'
    ,case plt.state
        when 1 then '丢失件待处理'
        when 2 then '疑似丢失件待处理'
        when 3 then '待工单回复'
        when 4 then '已工单回复'
        when 5 then '包裹未丢失'
        when 6 then '丢失件处理完成'
    end 闪人认定任务状态
from bi_pro.parcel_claim_task pct
left join bi_pro.parcel_lose_task plt on pct.pno = plt.pno
where
    pct.source = 12 -- L来源
    and pct.state in (7,8)
    and plt.state not in (5,6)
;

select
    wo.order_no
    ,wor.staff_info_id
    ,hsi.node_department_id
    ,wor.created_at
    ,hsi.state
from bi_pro.work_order wo
left join bi_pro.work_order_reply wor on wor.order_id = wo.id
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = wor.staff_info_id
where
    wo.order_no = '0416763084300226'

;

select
    t.pno
    ,ss.name 妥投网点
    ,wo.content '工单回复'
    ,group_concat(concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',sa1.object_key)) 签收凭证
    ,concat('https://fle-asset-internal.oss-ap-southeast-1.aliyuncs.com/',sa2.object_key) 其他凭证
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_03166 t  on t.pno = pi.pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join
    (
        select
            wo.pnos
            ,wor.content
            ,row_number() over (partition by wo.pnos order by wor.created_at desc) rn
        from bi_pro.work_order wo
        join tmpale.tmp_th_pno_03166 t on wo.pnos = t.pno
        left join bi_pro.work_order_reply wor on wor.order_id = wo.id
    ) wo on wo.pnos = t.pno and wo.rn = 1
left join fle_staging.sys_attachment sa1 on sa1.oss_bucket_key = t.pno and sa1.oss_bucket_type = 'DELIVERY_CONFIRM'
left join fle_staging.sys_attachment sa2 on sa2.oss_bucket_key = t.pno and sa2.oss_bucket_type = 'DELIVERY_CONFIRM_OTHER'
group by 1
;

select
    t.pno
    ,count(pct.id)
from fle_staging.pickup_claims_ticket pct
join tmpale.tmp_th_pno_0323 t on t.pno = pct.pno
group by 1


;


select
    ss.name
    ,ss.name name2
    ,count(ph.hno) num
from fle_staging.parcel_headless ph
left join fle_staging.sys_store ss on ss.id = ph.submit_store_id
left join fle_staging.sys_store ss2 on ss2.id = ph.claim_store_id
where
    ph.claim_store_id is not null
    and ph.state < 4
group by 1

;

select
    *
from fle_staging.parcel_headless ph
left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ph.operator_id

;

-- 临时取数，hub无头件

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
            from dwm.dwd_th_sls_pro_flash_point fp
            where
                fp.p_date >= '2023-03-01'
            group by 1,2
        ) fp
    left join fle_staging.sys_store ss on ss.id = fp.store_id
    where
        ss.category in (8,12)

;
















with pl AS
(
    select
        pl.*
    from
    (
        select
            pl.pno
            ,pl.state
            ,pl.duty_result
            ,pl.operator_id
            ,pl.created_at
            ,pl.updated_at
            ,pl.source
            ,row_number()over(partition by pl.pno order by pl.created_at) rn
        from bi_pro.parcel_lose_task pl
        where pl.created_at>='2023-04-01'
#         and pl.created_at<'2023-03-01'
        and pl.source=12
#         and pl.pno = 'TH20013U4VGY5M'
    )pl where pl.rn=1
)

# select
#     pl.pno
#     ,pl.created_at
#     ,pr.min_at
#     ,pr.max_at
#     ,pr.forceTakePhotoCategory
# from pl
# join fle_staging.parcel_info pi on pl.pno=pi.pno and pi.cod_enabled=1
# left join
# (
    select
        pr.pno
        ,convert_tz(min(pr.routed_at),'+00:00','+07:00') min_at
        ,convert_tz(max(pr.routed_at),'+00:00','+07:00') max_at
        ,json_extract(pr.extra_value,'$.forceTakePhotoCategory') forceTakePhotoCategory
    from rot_pro.parcel_route pr
    join pl on pr.pno=pl.pno
    where pr.routed_at>='2023-01-25'
#     and pr.routed_at<'2023-03-05'
    and pr.route_action='TAKE_PHOTO'
#     and pr.pno='TH20013U4VGY5M'
)pr on pl.pno=pr.pno

#  where forceTakePhotoCategory=3
;






-- 导出闪速认定

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
    ,oi.cogs_amount COGS
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
    ,wo.order_no 工单编号
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
from bi_pro.parcel_lose_task plt
left join fle_staging.parcel_info pi on pi.pno = plt.pno
left join fle_staging.order_info oi on oi.pno = pi.pno
left join fle_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join fle_staging.sys_store ss2 on ss2.id = pi.dst_store_id
left join fle_staging.fleet_van_proof fvp on fvp.id = substring_index(plt.fleet_routeids, '/', 1)
left join fle_staging.sys_store ss3 on ss3.id = plt.last_valid_store_id
left join bi_pro.work_order wo on wo.loseparcel_task_id = plt.id
where
    plt.created_at >= '2023-04-01'
    and plt.source = 3 -- C来源
    and plt.state < 5
