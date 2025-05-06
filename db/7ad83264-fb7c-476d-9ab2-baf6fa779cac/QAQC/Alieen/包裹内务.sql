select
    t.pno
    ,coalesce(loi.item_name, soi.item_name, toi.product_name) 包裹内务
from tmpale.tmp_ph_pno_lj_0508 t
left join dwm.drds_ph_lazada_order_info_d loi on loi.pno = t.ori_pno
left join dwm.drds_ph_shopee_item_info soi on soi.pno = t.ori_pno
left join dwm.dwd_ph_tiktok_order_item toi on toi.pno = t.ori_pno