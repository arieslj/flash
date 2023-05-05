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

