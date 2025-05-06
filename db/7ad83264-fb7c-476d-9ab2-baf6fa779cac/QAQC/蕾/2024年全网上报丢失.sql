select
    di.pno
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
    ,pi2.exhibition_weight/1000 as 重量_kg
    ,coalesce(loi.item_name, soi.item_name, toi.product_name) 产品名称
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,pi2.src_name 商家名称
    ,pi2.src_phone 商家电话
    ,case cdt.negotiation_result_category # 协商结果
        when 1 then '赔偿' -- 丢弃并赔偿（关闭订单，网点自行处理包裹）
        when 2 then '关闭订单(不赔偿不退货)' -- 丢弃（关闭订单，网点自行处理包裹）
        when 3 then '退货'
        when 4 then '退货并赔偿'
        when 5 then '继续配送'
        when 6 then '继续配送并赔偿'
        when 7 then '正在沟通中'
        when 8 then '丢弃包裹的，换单后寄回BKK' -- 丢弃（包裹发到内部拍卖仓）
        when 9 then '货物找回，继续派送'
        when 10 then '改包裹状态'
        when 11 then '需客户修改信息'
        when 12 then '丢弃并赔偿（包裹发到内部拍卖仓）'
        when 13 then 'TT退件新增“holding（15天后丢弃）”协商结果'
        else cdt.negotiation_result_category
    end 协商结果
    ,cdt.remark 备注
    ,pi2.cod_amount/100 cod
    ,pai.cogs_amount/100 cogs
from ph_staging.diff_info di
left join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
left join ph_staging.parcel_info pi on pi.pno = di.pno
left join ph_staging.parcel_info pi2 on pi2.pno = if(pi.returned = 1, pi.customary_pno, pi.pno)
left join ph_staging.parcel_additional_info pai on pai.pno = pi2.pno

left join dwm.drds_ph_lazada_order_info_d loi on loi.pno = pi2.pno
left join dwm.drds_ph_shopee_item_info soi on soi.pno = pi2.pno
left join dwm.dwd_ph_tiktok_order_item toi on toi.pno = pi2.pno

left join ph_staging.ka_profile kp on kp.id = pi2.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id

left join ph_staging.sys_store ss on ss.id = di.store_id
where
    di.diff_marker_category = 20 -- 货物破损
    and di.created_at > '2023-12-31 16:00:00'
   -- and di.pno = 'P611948983ZAU'