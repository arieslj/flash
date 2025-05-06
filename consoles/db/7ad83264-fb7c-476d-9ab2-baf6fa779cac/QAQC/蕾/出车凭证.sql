select
    fvp.relation_no
    ,pi.exhibition_weight/1000 重量
    ,concat_ws('*', pi.exhibition_length, pi.exhibition_width, pi.exhibition_height) 尺寸
    ,fvp.proof_id 出车凭证
    ,concat(ddd.element, ddd.CN_element) 最后有效路由
    ,ss.name  最后操作网点
    ,pd.resp_store_updated 最后操作时间
from ph_staging.fleet_van_proof_parcel_detail fvp
left join ph_staging.parcel_info pi on pi.pno = fvp.relation_no
left join ph_bi.parcel_detail pd on pd.pno = fvp.relation_no
left join ph_staging.sys_store ss on ss.id = pd.resp_store_id
left join dwm.dwd_dim_dict ddd on ddd.element = pd.last_valid_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    fvp.proof_id in ('PN5SR2410BBZ','PN5SR2410BCE','PN5SR2410BCH','PN5SR2410BCW','PN5SR2410BCR','PN5SR2410BD5','PN5SR2410BE1','PN5SR2410BEO','PN5SR2410BEK','PN5SR2410BDY','PN5SR2410BEJ','PN5SR2410BEU','PN5SR2410BG0','PN5SR2410BG2','PN5SR2410BG9','PN5SR2410BGD','PN5SR2410BGH','PN5SR2410BGJ')
    and fvp.relation_category in (1,3)
    and pi.state in (8,2)