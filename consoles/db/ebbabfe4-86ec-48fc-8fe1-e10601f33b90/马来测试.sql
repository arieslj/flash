select 'L来源高度疑似丢失-C升L' as 问题来源
      ,date(plt.created_at) 任务生成日期
      ,plt.pno as 运单号
      ,ss.name as 始发网点
      ,ss1.name as 目的地网点
      ,case when (ss.province_code not in ('MY14','MY15','MY16') and ss1.province_code in ('MY14','MY15','MY16'))
             or (ss1.province_code not in ('MY14','MY15','MY16') and ss.province_code in ('MY14','MY15','MY16'))
            then '是' else '否' end as 是否跨马
      ,date(convert_tz(pi.created_at, '+00:00', '+08:00')) as 揽件日期
      ,pr.routed_at as 最后有效路由时间
      ,pr.route_action as 最后有效路由动作
      ,ss2.name as 最后有效路由网点
from my_bi.parcel_lose_task plt
left join my_staging.parcel_info pi on plt.pno =pi.pno
left join my_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join my_staging.sys_store ss1 on ss1.id = pi.dst_store_id
left join (
  select distinct pr.pno
    ,convert_tz(pr.routed_at,'+00:00','+08:00') routed_at
    ,pr.route_action
    ,pr.store_id
    ,row_number()over(partition by pr.pno order by pr.routed_at desc) rnk
  from my_staging.parcel_route pr
  where pr.routed_at>=convert_tz('2025-02-01','+08:00','+00:00') and pr.routed_at<=convert_tz('2025-03-31','+08:00','+00:00')
  and pr.route_action in ('RECEIVED'
                            ,'RECEIVE_WAREHOUSE_SCAN'
                            ,'SORTING_SCAN'
                            ,'DELIVERY_TICKET_CREATION_SCAN'
                            ,'ARRIVAL_WAREHOUSE_SCAN'
                            ,'SHIPMENT_WAREHOUSE_SCAN'
                            ,'DETAIN_WAREHOUSE'
                            ,'DELIVERY_CONFIRM'
                            ,'DIFFICULTY_HANDOVER'
                            ,'DELIVERY_MARKER'
                            ,'REPLACE_PNO'
                            ,'SEAL'
                            ,'UNSEAL'
                            ,'PARCEL_HEADLESS_PRINTED'
                            ,'STAFF_INFO_UPDATE_WEIGHT'
                            ,'STORE_KEEPER_UPDATE_WEIGHT'
                            ,'STORE_SORTER_UPDATE_WEIGHT'
                            ,'DISCARD_RETURN_BKK'
                            ,'DELIVERY_TRANSFER'
                            ,'PICKUP_RETURN_RECEIPT'
                            ,'FLASH_HOME_SCAN'
                            ,'seal.ARRIVAL_WAREHOUSE_SCAN'
                            ,'INVENTORY'
                            ,'SORTING_SCAN'
                            ,'DELIVERY_PICKUP_STORE_SCAN'
                            ,'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE'
                            ,'REFUND_CONFIRM'
                            ,'ACCEPT_PARCEL')
)pr on plt.pno = pr.pno and pr.rnk = 1
left join my_staging.sys_store ss2 on ss2.id = pr.store_id
where plt.created_at >= '2025-02-01' and plt.created_at <= '2025-03-31'
and plt.source_id like '%_c_l_%' -- c to L


;


select
    pi.pno
    ,pi.src_name 卖家名称
    ,pi.src_phone 卖家电话
from my_staging.parcel_info pi
where
    pi.pno in ('MT040323V85M0Z',
'MT040223V3GE9Z',
'MT030623V38K1Z',
'MT040823V3333Z',
'MT100623UYQ85Z',
'MT110623V1SJ0Z',
'MT100523UXB73Z',
'MT030123UV7J9Z',
'MT010223UV093Z')

;


select

    case plt.source
        when 1 then 'A-问题件-丢失'
        when 2 then 'B-记录本-丢失'
        when 3 then 'C-包裹状态未更新'
        when 4 then 'D-问题件-破损/短少'
        when 5 then 'E-记录本-索赔-丢失'
        when 6 then 'F-记录本-索赔-破损/短少'
        when 7 then 'G-记录本-索赔-其他'
        when 8 then 'H-包裹状态未更新-IPC计数'
        when 9 then 'I-问题件-外包装破损险'
        when 10 then 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end 问题来源渠道
    ,case
        when plt.source_id like '%_c_l_%' then 'ctol'
        when plt.source_id like '%_l' then 'force'
    end L来源分类
    ,max(plt.created_at)
    ,count(plt.id)
    ,max(plt.parcel_created_at)
from my_bi.parcel_lose_task plt
where
    plt.source not in (11)
    and plt.last_valid_routed_at is null
    and plt.last_valid_action is not null
    and plt.created_at > '2025-01-01'
    -- and plt.source = 7
group by 1,2

;

select
    case
        when tebcid.client_id is not null then tebcid.client_name
        when kp.id is not null and tebcid.client_id is null then '普通ka'
        when kp.id is null then '小c'
    end as  客户类型
    ,case plt.source
        when 1 then 'A-问题件-丢失'
        when 2 then 'B-记录本-丢失'
        when 3 then 'C-包裹状态未更新'
        when 4 then 'D-问题件-破损/短少'
        when 5 then 'E-记录本-索赔-丢失'
        when 6 then 'F-记录本-索赔-破损/短少'
        when 7 then 'G-记录本-索赔-其他'
        when 8 then 'H-包裹状态未更新-IPC计数'
        when 9 then 'I-问题件-外包装破损险'
        when 10 then 'J-问题记录本-外包装破损险'
        when 11 then 'K-超时效包裹'
        when 12 then 'L-高度疑似丢失'
    end 问题来源渠道
    ,substr(plt.parcel_created_at, 1, 7) 月份
    ,count(plt.id) cnt
from my_bi.parcel_lose_task plt
left join dwm.tmp_ex_big_clients_id_detail tebcid on tebcid.client_id = plt.client_id
left join my_staging.ka_profile kp on kp.id = plt.client_id
where
    plt.state in (1,2,3,4)
    and plt.parcel_created_at < '2025-01-01'
group by 1,2,3
order by 3,1,2

;

select
    plt.pno
    ,ddd.cn_element
    ,ci.id
    ,ci.submitter_id
    ,sd.name
    ,plt.created_at
from my_bi.parcel_lose_task plt
left join my_staging.customer_issue ci on ci.id = plt.source_id
left join dwm.dwd_dim_dict ddd on ddd.element = ci.request_sub_type and ddd.db = 'my_staging' and ddd.tablename = 'customer_issue' and ddd.fieldname = 'request_sub_type'
left join my_bi.hr_staff_info hsi on hsi.staff_info_id = ci.submitter_id
left join my_staging.sys_department sd on sd.id = hsi.sys_department_id
where
     plt.state in (1,2,3,4)
    and plt.parcel_created_at < '2025-01-01'
    and plt.source = 5

;





select
    *
from my_nl.abnormal_weight_balance aw
where
    aw.pno = 'M11071YCTNSAA0'
;


select
    date_format(awb.revise_at,'%Y-%m') '任务年月'
    ,count(awb.id) '任务数'
    ,count(if(awb.type = 2  and date(awb.updated_at) <= date(date_add(awb.revise_at,interval 1 day)),awb.id,null)) '时效内任务量'
    ,count(if(awb.type = 2  and date(awb.updated_at) <= date(date_add(awb.revise_at,interval 1 day)),awb.id,null))/count(awb.id) '时效内处理率'
from my_nl.abnormal_weight_balance awb
where
    awb.revise_at >= '${sdate}' and awb.revise_at < date_add('${edate}',interval 1 day)
    and awb.type <> 4
    and json_extract(awb.extra_info, '$.reweight_by') not like '%ai%'
#and pno ='MT010224TWPA5Z'
group by 1