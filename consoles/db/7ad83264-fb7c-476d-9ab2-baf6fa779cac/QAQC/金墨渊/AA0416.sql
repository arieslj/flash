select
    pi.pno
    ,ddd.CN_element 操作状态
    ,pd.resp_store_updated 操作时间
    ,pi.cod_amount/100 cod
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
from ph_staging.parcel_info pi
left join ph_bi.parcel_detail pd on pi.pno = pd.pno
left join dwm.dwd_dim_dict ddd on ddd.element = pd.last_valid_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pd.resp_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    pi.state in (1,2,3,4,6)
    and pi.returned = 0
    and pi.client_id = 'AA0164'