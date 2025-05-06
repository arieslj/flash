select
    t.pno
    ,count(pr.id) pr_cnt
from ph_staging.parcel_route pr
join tmpale.tmp_ph_pno_lj_0311 t on t.pno = pr.pno
where
    pr.routed_at > '2023-11-01'
    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
group by 1

;



select
    pi.pno
    ,pi.src_name 卖家
    ,dp.store_name 揽收网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,pi.cod_amount/100 cod
    ,oi.cogs_amount/100 cogs
    ,oi.insure_declare_value/100
    ,ddd.CN_element 最后一步有效路由
from ph_staging.parcel_info pi
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.ticket_pickup_store_id and dp.stat_date = curdate()
left join ph_staging.order_info oi on oi.pno = pi.pno
left join ph_bi.parcel_detail pd on pd.pno = pi.pno
left join dwm.dwd_dim_dict ddd on ddd.element = pd.last_valid_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
where
    pi.created_at > '2024-06-12 16:00:00'
    and pi.created_at < '2024-06-17 16:00:00'
    and pi.client_id = 'CA4008'
    and pi.returned = 0

;


select
    t.pno
    ,count(pr.id) 交接次数
from ph_staging.parcel_route pr
join tmpale.tmp_ph_pno_lj_0807 t on t.pno = pr.pno
where
    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
group by 1