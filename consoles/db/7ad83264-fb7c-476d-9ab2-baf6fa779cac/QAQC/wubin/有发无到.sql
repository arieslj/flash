select
    pssn.pno 单号
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,pi.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 平台
    ,case pi.article_category
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
    ,pi.exhibition_weight 物品重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 物品体积
    ,oi.cod_amount/100 COD金额
    ,oi.cogs_amount/100 COGS金额
    ,ss.name 揽件网点
    ,ss2.name 目的地网点
    ,ft.store_name 装车网点
    ,pssn.store_name 卸车网点
    ,pssn.van_in_proof_id 车辆凭证
from dw_dmd.parcel_store_stage_new pssn
left join ph_bi.fleet_time ft on ft.next_store_id = pssn.store_id and ft.proof_id = pssn.van_in_proof_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pssn.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.parcel_info pi on pi.pno = pssn.pno and pi.created_at > date_sub(curdate(), interval 3 month)
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
left join
    (
        select
            oi.pno
            ,oi.cod_amount
            ,oi.cogs_amount
        from ph_staging.order_info oi
        where
            oi.created_at > date_sub(curdate(), interval 4 month )
    ) oi on if(pi.returned = 1, pi.customary_pno, pi.pno) = oi.pno
where
    pssn.van_arrived_at > date_sub(curdate() , interval 1 day)
    and pssn.van_arrived_at < curdate()
    and pssn.first_valid_routed_at is null


;

