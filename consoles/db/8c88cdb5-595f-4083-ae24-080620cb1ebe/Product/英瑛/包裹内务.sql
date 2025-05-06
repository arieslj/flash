select
    t.pno
    ,pi.client_id
    ,greatest(),if
    ,coalesce(loi.item_name, soi.item_name, toi.product_name) 包裹内务
    ,coalesce(loi.total_item_quantity, )
from tmpale.tmp_ph_pno_lj_0315_v3 t
left join dwm.dim_th_sys_store_rd dtssr
left join fle_staging.parcel_info pi on pi.returned_pno = t.pno
left join dwm.drds_lazada_order_info_d loi on loi.pno = pi.pno
left join dwm.drds_ph_shopee_item_info soi on soi.pno = pi.pno
left join dwm.drds_tiktok_order_item toi on toi.pno = pi.pno