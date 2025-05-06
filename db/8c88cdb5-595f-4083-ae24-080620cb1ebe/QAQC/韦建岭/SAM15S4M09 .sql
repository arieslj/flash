select
    fvp.relation_no
    ,concat(pi.src_name, pi.src_phone) 发件人信息
    ,concat(pi.dst_name, pi.dst_phone) 收件人信息
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,pick_ss.name 揽收网点
    ,convert_tz(pi.created_at, '+00:00', '+07:00') 揽收时间
    ,pi.ticket_pickup_staff_info_id 揽收员工
    ,dst_ss.name 目的地网点
    ,pi.cod_amount/100 COD
    ,case pi.article_category
        when 0 then '文件/document'
        when 1 then '干燥食品/dry food'
        when 2 then '日用品/daily necessities'
        when 3 then '数码产品/digital product'
        when 4 then '衣物/clothes'
        when 5 then '书刊/Books'
        when 6 then '汽车配件/auto parts'
        when 7 then '鞋包/shoe bag'
        when 8 then '体育器材/sports equipment'
        when 9 then '化妆品/cosmetics'
        when 10 then '家居用具/Houseware'
        when 11 then '水果/fruit'
        when 99 then '其它/other'
    end 物品类型
    ,pi.exhibition_weight/1000 重量kg
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 体积
    ,case pi.insured
        when 1 then '保价'
        when 0 then '不保价'
    end 保价情况
    ,oi.cogs_amount/100 COGS
from fle_staging.fleet_van_proof_parcel_detail fvp
left join fle_staging.parcel_info pi on pi.pno = fvp.relation_no
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join fle_staging.ka_profile kp on kp.id = pi.client_id
left join fle_staging.sys_store pick_ss on pick_ss.id = pi.ticket_pickup_store_id
left join fle_staging.sys_store dst_ss on dst_ss.id = pi.dst_store_id
left join fle_staging.order_info oi on oi.pno = fvp.relation_no
where
    fvp.relation_category in (1,3)
    and fvp.proof_id = 'KKC16XMW09'
    and fvp.state < 3
    and fvp.created_at > '2024-03-01'