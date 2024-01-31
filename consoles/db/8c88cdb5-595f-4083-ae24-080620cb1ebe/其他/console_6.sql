select
    case di.diff_marker_category # 疑难原因
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
        when 53 then 'lazada仓库拒收'
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
    end as 疑难件原因
    ,if(cdt.operator_id in (10000,10001,10002,10003), '自动处理', '人工处理') 处理方式
#     ,di.created_at 创建时间
#     ,cdt.updated_at 更新时间
    ,bc.client_name 客户名称
#     ,cdt.first_operated_at 第一次处理时间
    ,case
        when 0 then '客服未处理'
        when 1 then '已处理完毕'
        when 2 then '正在沟通中'
        when 3 then '财务驳回'
        when 4 then '客户未处理'
        when 5 then '转交闪速系统'
        when 6 then '转交QAQC'
    end as 处理状态
#     ,case cdt.negotiation_result_category
#         when 1 then '赔偿'
#         when 2 then '关闭订单(不赔偿不退货)'
#         when 3 then '退货'
#         when 4 then '退货并赔偿'
#         when 5 then '继续配送'
#         when 6 then '继续配送并赔偿'
#         when 7 then '正在沟通中'
#         when 8 then '丢弃包裹的，换单后寄回BKK'
#         when 9 then '货物找回，继续派送'
#         when 10 then '改包裹状态'
#         when 11 then '需客户修改信息'
#         when 12 then '丢弃并赔偿（包裹发到内部拍卖仓）'
#         when 13 then 'TT退件新增“holding（15天后丢弃）”协商结果'
#     end as 协商结果
#     ,case  cdt.service_type
#         when 1 then '总部客服'
#         when 2 then 'miniCS客服'
#         when 3 then 'FH客服'
#     end  客服类型
#     ,case cdt.hand_over_normal_cs_reason # 状态
#         when 1 then '协商不一致'
#         when 2 then '无法联系客户'
#     end as 转交总部cs理由
    ,case
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 <= 1  then '1小时内'
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 > 1 and timestampdiff(second , di.created_at, cdt.updated_at)/3600 <= 2 then '1-2小时'
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 > 2 and timestampdiff(second , di.created_at, cdt.updated_at)/3600 <= 3 then '2-3小时内'
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 > 3 and timestampdiff(second , di.created_at, cdt.updated_at)/3600 <= 4 then '3-4小时内'
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 > 4 and timestampdiff(second , di.created_at, cdt.updated_at)/3600 <= 5 then '4-5小时内'
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 > 5 and timestampdiff(second , di.created_at, cdt.updated_at)/3600 <= 6 then '5-6小时内'
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 > 6 and timestampdiff(second , di.created_at, cdt.updated_at)/3600 <= 12 then '6-12小时内'
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 > 12 and timestampdiff(second , di.created_at, cdt.updated_at)/3600 <= 24 then '12-24小时内'
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 > 24 and timestampdiff(second , di.created_at, cdt.updated_at)/3600 <= 49 then '1-2天内'
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 > 48 and timestampdiff(second , di.created_at, cdt.updated_at)/3600 <= 168 then '2-7天内'
        when timestampdiff(second , di.created_at, cdt.updated_at)/3600 > 168  then '7天以上'
    end 处理时效
#     ,timestampdiff(hour, di.created_at, cdt.first_operated_at)/24 第一次处理时效_天数
    ,count(distinct di.id) 个数
from fle_staging.diff_info di
left join fle_staging.customer_diff_ticket cdt on di.id = cdt.diff_info_id
join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = cdt.client_id and bc.client_name in ('lazada', 'shopee', 'tiktok')
where
    di.created_at >= '2023-04-30 17:00:00'
    and di.created_at < '2023-05-31 17:00:00'
#     and cdt.state = 1 -- 已处理
#     and cdt.operator_id not in (10000,10003,10002)
group by 1,2,3,4,5
;


select
    pr.store_name
    ,count(distinct pr.pno) holding包裹数
from
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.store_id
            ,pr.store_name
        from rot_pro.parcel_route pr
        where
            pr.route_action = 'REFUND_CONFIRM'
            and pr.routed_at >= '2023-04-30 17:00:00'
            and pr.routed_at < '2023-05-31 17:00:00'
    ) pr
# left join fle_staging.parcel_info pi on pi.pno = pr.pno
group by 1
order by 2 desc
;



select
    a.pno
    ,a.pickup_weight 揽收重量
    ,a.double_weight 最后一次复称重量
    ,if(floor(a.pickup_weight) = floor(a.double_weight), 0, 1) 是否跨公斤段
    ,if(abs(a.double_weight - a.pickup_weight) > 1, 1, 0) 是否超1kg以上
    ,if(abs(a.double_weight - a.pickup_weight) > 2, 1, 0) 是否超2kg以上
from
    (
        select
            pi.pno
            ,pi.exhibition_weight/1000 pickup_weight
            ,pwr.after_weight/1000 double_weight
        from fle_staging.parcel_info pi
        join tmpale.tmp_th_pno_0602 t on t.pno = pi.pno
        left join
            (
                select
                    pwr.pno
                    ,pwr.after_weight
                    ,row_number() over (partition by pwr.pno order by pwr.created_at desc ) rk
                from dwm.drds_parcel_weight_revise_record_d pwr
                join tmpale.tmp_th_pno_0602 t on t.pno = pwr.pno
            ) pwr on pi.pno = pwr.pno and pwr.rk = 1
    ) a
;

select
    count(distinct pi.pno)
from fle_staging.parcel_info pi
join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id and bc.client_name = 'tiktok'
where
    pi.created_at >= '2023-03-31 17:00:00'
    and pi.created_at < '2023-04-30 17:00:00'
    and pi.returned = 0
;


select
    pi.pno
    ,toi.shop_id seller_id
    ,toi.shop_name seller_name
    ,pi.exhibition_weight 重量
    ,concat_ws('*',pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
from fle_staging.parcel_info pi
join tmpale.tmp_th_pno_0602 t on t.pno = pi.pno
left join dwm.drds_tiktok_order_info toi on toi.pno=pi.pno
where
   ( pi.exhibition_weight = 5000 and pi.exhibition_length = 20 and pi.exhibition_width = 20 and pi.exhibition_height = 20 )
    or ( pi.exhibition_weight = 10000 and pi.exhibition_length = 50 and pi.exhibition_width = 50 and pi.exhibition_height = 50)

;
select
    di.pno
    ,di.id
from fle_staging.diff_info di
left join fle_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = cdt.client_id and bc.client_name in ('lazada', 'shopee', 'tiktok')
where
    cdt.operator_id = '68683'
    and di.diff_marker_category = 39


;



select
    a.*
from
    (
        select
            fvp.proof_id
            ,fvp.pack_no
            ,fvp.relation_no
            ,ss2.id
            ,ss2.name
            ,count(fvp.relation_no) over (partition by fvp.pack_no, ss2.id) ss_num
            ,count(fvp.relation_no) over (partition by fvp.pack_no) pno_num
        from fleet_van_proof_parcel_detail fvp
        left join fle_staging.parcel_info pi on pi.pno = fvp.relation_no
        left join fle_staging.sys_store ss on ss.id = pi.dst_store_id
        left join fle_staging.sys_store ss2 on ss2.id = if(ss.category in (8,12), ss.id, substring_index(ss.ancestry, '/', -1))
        where
            fvp.relation_category = 3
            and fvp.created_at < date_sub(curdate(), interval 7 hour )
            and fvp.created_at >= date_sub(curdate(), interval 31 hour )
            and fvp.pack_no is not null
    ) a
where
    a.ss_num < a.pno_num

;

/*
        =====================================================================+
        表名称：tmp_th_lost_client_new_retail
        功能描述：retail客户流失情况

        需求来源：体系建设
        编写人员: 梁俊杰
        设计日期：2023-05-29
      	修改日期:
      	修改人员:
      	修改原因:
      -----------------------------------------------------------------------
      ---存在问题：
      -----------------------------------------------------------------------
      +=====================================================================
      */

DELETE from tmpale.`tmp_th_lost_client_new_retail` where 计算日期=date_sub(curdate(),1);
insert into tmpale.`tmp_th_lost_client_new_retail`(client_id,客户类别,`网点-工号`,归属大区,归属部门,最后发货日期,最后发货日期前45天发货量,计算日期)


(
select nw.*
FROM (
-- Shop/SP/BDC
SELECT pi.client_id
,case when pi.流失前单量/45<10 then 'E'
when pi.流失前单量/45>=10 and pi.流失前单量/45<50 then 'D'
when pi.流失前单量/45>=50 and pi.流失前单量/45<200 then 'C'
when pi.流失前单量/45>=200 and pi.流失前单量/45<300 then 'B'
when pi.流失前单量/45>=300 then 'A' end as 客户类别
,pi.归属网点 '网点-工号'
,pi.归属大区
,pi.归属部门
,pi.最后发货日期
,pi.流失前单量 最后发货日期前45天发货量
,pi.date_id 计算日期
FROM (
SELECT pi.`client_id`
,count(distinct(pi.pno)) 流失前单量
,gs.name 归属网点
,kp.staff_info_id 工号
,mr.name 归属大区
,case WHEN pi.`client_id` IN ('CA5901','AA0413','AA0302') and pi.`customer_type_category` ='2'  THEN 'FFM'
WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '20001' and pi.`customer_type_category` ='2' THEN 'FFM'
WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '4' and pi.`customer_type_category` ='2' THEN 'Network_KA'
WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '34' and pi.`customer_type_category` ='2' THEN 'BULKY_KA'
WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '40' and pi.`customer_type_category` ='2' THEN 'Sales_KA'
WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '13' and if(kp.`account_type_category` = '3',hs2.`node_department_id`, hs.`node_department_id`) IN ('1098','1099','1100','1101') and pi.`customer_type_category` ='2' THEN 'Sales_KA'
WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '13' and pi.`customer_type_category` ='2' THEN 'Shop_KA'
WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '388' AND if(kp.`account_type_category` = '3',kp.`agent_id`, kp.`id`) = 'BF5633' and pi.`customer_type_category` ='2' THEN 'PMD-CFM'
WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '388' and pi.`customer_type_category` ='2' THEN 'PMD-KAM'
WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '545' and pi.`customer_type_category` ='2' THEN 'Bulky Business Development'
WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '3' and pi.`customer_type_category` ='2' THEN 'Customer Service'
when st.`category` in ('1') and pi.`customer_type_category` ='1' then 'Network_C'
when st.`category` in ('10','13') and pi.`customer_type_category` ='1' then 'Bulky_C'
when st.`category` in ('4','5','7') and pi.`customer_type_category` ='1' then 'Shop_C'
when st.`category` ='6' and pi.`customer_type_category` ='1' then 'FH_C'
END AS 归属部门
,max(date(convert_tz(pi.created_at,'+00:00','+07:00'))) 最后发货日期
,date_sub(curdate(),1) date_id
FROM `fle_staging`.`parcel_info` pi
LEFT JOIN fle_staging. ka_profile kp on pi.`client_id` =kp.`id`
LEFT JOIN fle_staging. ka_profile kp2 on kp2.`id` =kp.`agent_id`
LEFT JOIN bi_pro. hr_staff_info hs on kp.`staff_info_id` = hs.`staff_info_id`
LEFT JOIN bi_pro. hr_staff_info hs2 on kp2.`staff_info_id` = hs2.`staff_info_id`
LEFT JOIN `fle_staging`.`sys_store` st on st.`id` =pi.`ticket_pickup_store_id`
LEFT JOIN `dwm`.`tmp_ex_big_clients_id_detail` bc on bc.`client_id` =pi.`client_id`
left join `fle_staging`.`sys_store` gs on gs.`id` =kp.store_id
left join fle_staging.sys_manage_region mr on mr.id=gs.manage_region
left join bi_pro.hr_staff_info hr on hr.`staff_info_id` =kp.staff_info_id
WHERE pi.created_at >= convert_tz(date_sub(curdate(),75),'+07:00','+00:00')
and pi.created_at < convert_tz(date_sub(curdate(),30),'+07:00','+00:00')
and pi.state < 9
and pi.`returned` =0
and pi.customer_type_category=2
and bc.client_id is null
GROUP BY 1
) pi
WHERE pi.归属部门 in ('Network_KA','BULKY_KA','Shop_KA')
) nw
left join `fle_staging`.`parcel_info` pi on pi.client_id=nw.client_id and pi.created_at >= convert_tz(date_sub(curdate(),30),'+07:00','+00:00') and pi.created_at < convert_tz(curdate(),'+07:00','+00:00') and pi.state < 9 and pi.`returned` =0
WHERE pi.client_id is null
and nw.最后发货日期=date_sub(curdate(),31)
)

union all

(
select sl.*
FROM (
-- sales
SELECT pi.client_id
,case when pi.流失前单量/45<10 then 'E'
when pi.流失前单量/45>=10 and pi.流失前单量/45<50 then 'D'
when pi.流失前单量/45>=50 and pi.流失前单量/45<200 then 'C'
when pi.流失前单量/45>=200 and pi.流失前单量/45<300 then 'B'
when pi.流失前单量/45>=300 then 'A' end as 客户类别
,pi.工号 '网点-工号'
,pi.归属大区
,pi.归属部门
,pi.最后发货日期
,pi.流失前单量 最后发货日期前45天发货量
,pi.date_id 计算日期
FROM (
SELECT pi.`client_id`
,count(distinct(pi.pno)) 流失前单量
,gs.name 归属网点
,kp.staff_info_id 工号
,mr.name 归属大区
,case WHEN pi.`client_id` IN ('CA5901','AA0413','AA0302') and pi.`customer_type_category` ='2'  THEN 'FFM'
WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '20001' and pi.`customer_type_category` ='2' THEN 'FFM'
WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '4' and pi.`customer_type_category` ='2' THEN 'Network_KA'
WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '34' and pi.`customer_type_category` ='2' THEN 'BULKY_KA'
WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '40' and pi.`customer_type_category` ='2' THEN 'Sales_KA'
WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '13' and if(kp.`account_type_category` = '3',hs2.`node_department_id`, hs.`node_department_id`) IN ('1098','1099','1100','1101') and pi.`customer_type_category` ='2' THEN 'Sales_KA'
WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '13' and pi.`customer_type_category` ='2' THEN 'Shop_KA'
WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '388' AND if(kp.`account_type_category` = '3',kp.`agent_id`, kp.`id`) = 'BF5633' and pi.`customer_type_category` ='2' THEN 'PMD-CFM'
WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '388' and pi.`customer_type_category` ='2' THEN 'PMD-KAM'
WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '545' and pi.`customer_type_category` ='2' THEN 'Bulky Business Development'
WHEN if(kp.`account_type_category` = '3',kp2.`department_id`, kp.`department_id`) = '3' and pi.`customer_type_category` ='2' THEN 'Customer Service'
when st.`category` in ('1') and pi.`customer_type_category` ='1' then 'Network_C'
when st.`category` in ('10','13') and pi.`customer_type_category` ='1' then 'Bulky_C'
when st.`category` in ('4','5','7') and pi.`customer_type_category` ='1' then 'Shop_C'
when st.`category` ='6' and pi.`customer_type_category` ='1' then 'FH_C'
END AS 归属部门
,max(date(convert_tz(pi.created_at,'+00:00','+07:00'))) 最后发货日期
,date_sub(curdate(),1) date_id
FROM `fle_staging`.`parcel_info` pi
LEFT JOIN fle_staging. ka_profile kp on pi.`client_id` =kp.`id`
LEFT JOIN fle_staging. ka_profile kp2 on kp2.`id` =kp.`agent_id`
LEFT JOIN bi_pro. hr_staff_info hs on kp.`staff_info_id` = hs.`staff_info_id`
LEFT JOIN bi_pro. hr_staff_info hs2 on kp2.`staff_info_id` = hs2.`staff_info_id`
LEFT JOIN `fle_staging`.`sys_store` st on st.`id` =pi.`ticket_pickup_store_id`
LEFT JOIN `dwm`.`tmp_ex_big_clients_id_detail` bc on bc.`client_id` =pi.`client_id`
left join `fle_staging`.`sys_store` gs on gs.`id` =kp.store_id
left join fle_staging.sys_manage_region mr on mr.id=gs.manage_region
left join bi_pro.hr_staff_info hr on hr.`staff_info_id` =kp.staff_info_id
WHERE pi.created_at >= convert_tz(date_sub(curdate(),90),'+07:00','+00:00')
and pi.created_at < convert_tz(date_sub(curdate(),45),'+07:00','+00:00')
and pi.state < 9
and pi.`returned` =0
and pi.customer_type_category=2
and bc.client_id is null
GROUP BY 1
) pi
WHERE pi.归属部门 in ('Sales_KA')
) sl
left join `fle_staging`.`parcel_info` pi on pi.client_id=sl.client_id and pi.created_at >= convert_tz(date_sub(curdate(),45),'+07:00','+00:00') and pi.created_at < convert_tz(curdate(),'+07:00','+00:00') and pi.state < 9 and pi.`returned` =0
WHERE pi.client_id is null
and sl.最后发货日期=date_sub(curdate(),46)
)

;

select
    count(id)
from bi_pro.parcel_lose_task plt
where
    plt.state = 6
    and plt.created_at

;
select
    count(pi.pno)
    ,min(pi.created_at)
from fle_staging.parcel_info pi
where
     pi.state not in (5,7,8,9)
    and pi.created_at >= '2023-01-01'
    and pi.created_at >