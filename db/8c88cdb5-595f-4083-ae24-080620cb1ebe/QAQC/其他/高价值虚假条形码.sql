select
    distinct
    pr.pno 运单号
    ,ddd.CN_element 路由
    ,pr.staff_info_name 操作人
    ,pr.staff_info_id 操作人工号
    ,pr.store_name 操作网点
    ,convert_tz(pr.routed_at, '+00:00', '+07:00') 操作时间
    ,pi.cod_amount/100 cod
    ,ss.name 目的地网点
from rot_pro.parcel_route pr
left join fle_staging.parcel_info pi on pi.pno = pr.pno and pi.created_at > '2024-04-01'
left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join fle_staging.sys_store ss on ss.id = pi.dst_store_id
left join bi_pro.parcel_lose_task plt on plt.pno = pr.pno
where
    pr.routed_at > '2024-06-25 17:00:00'
    and json_extract(pr.extra_value, '$.illegalBarCode') = true
    and pi.cod_amount > 1000000
    and plt.pno is not null