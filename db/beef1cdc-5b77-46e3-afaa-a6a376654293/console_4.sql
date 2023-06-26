select
    pi.pno
    ,pi.created_at
    ,pi.finished_at
    ,pi.client_id
    ,pi.src_name
    ,pi.src_detail_address
    ,pi.dst_name
    ,pi.dst_detail_address
    ,case pi.article_category
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
     end  `物品类型`
    ,pi.cod_amount/100 cod
    ,pi.exhibition_weight
    ,pi.chicun
    ,ss1.name
    ,ss2.name
    ,kp.authentication_citizen_id
    ,kp.bank_name
    ,kp.account_holder
    ,kp.bank_account_no
from
    (
        select
            pi.pno
            ,pi.created_at
            ,pi.finished_at
            ,pi.client_id
            ,pi.src_name
            ,pi.src_detail_address
            ,pi.dst_name
            ,pi.dst_detail_address
            ,pi.article_category
            ,cast(pi.cod_amount as int) cod_amount
            ,pi.exhibition_weight
            ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) chicun
            ,pi.ticket_pickup_store_id
            ,pi.ticket_delivery_store_id
        from fle_dwd.dwd_fle_parcel_info_di pi
        where
            pi.p_date >= '2023-01-01'
            and pi.pno in ('TH44013WWPP23A','TH15013W0PY21B','THT15017Q2CC6Z','TH38013W6F9B1N','TH60072V2M293A','TH01162RDYF27B','TH6005WVSP41A','TH600543TPQM4A','TH03053UKZHQ3A','TH38013W6F9B1N','TH600543TPQM4A','TH03053UKZHQ3A','THT49037R3EQ8Z','TH49033UFW074F','TH49033UAWMH5F','TH49033TUMVA6F','TH49033TSX0H7F','TH49033TBFKH8F','TH49033TBZ325F','TH49033T6DQH8F','TH49033SJGB15F','TH49033SGF4X1F','TH0133213KH22E','TH01171PGM2U1B')
    ) pi
join
    (
        select
            kp.id
            ,kp.bank_name
            ,kp.account_holder
            ,kp.authentication_citizen_id
            ,kp.bank_account_no
        from fle_dim.dim_fle_ka_profile_da kp
        where
            kp.p_date = date_sub(`current_date`(), 1)
    ) kp on pi.client_id = kp.id
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss1 on ss1.id = pi.ticket_pickup_store_id
left join
    (
        select
            *
        from fle_dim.dim_fle_sys_store_da ss
        where
            ss.p_date = date_sub(`current_date`(), 1)
    ) ss2 on ss2.id = pi.ticket_delivery_store_id