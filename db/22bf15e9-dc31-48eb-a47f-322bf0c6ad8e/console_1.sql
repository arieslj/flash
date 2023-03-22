select
    plt.created_at 预警日期
    ,plt.pno 单号
    ,pi.cod_amount/100 COD金额
    ,bc.client_name 客户
    ,dt.store_name 网点
    ,dt.piece_name 片区
    ,dt.region_name 大区
    ,if(di.pno is not null , '是', '否') 货物丢失
    ,if(di2.pno is not null , '是', '否') 已妥投未回COD
from bi_pro.parcel_lose_task plt
left join bi_pro.parcel_detail pd on pd.pno = plt.pno
left join fle_staging.parcel_info pi on pi.pno = plt.pno
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = plt.client_id
left join dwm.dim_th_sys_store_rd dt on dt.store_id = pd.resp_store_id and dt.stat_date = date_sub(curdate(), interval 1 day)
left join fle_staging.diff_info di on di.pno = plt.pno and di.diff_marker_category in (7,22)
left join fle_staging.diff_info di2 on di2.pno = plt.pno and di2.diff_marker_category in (28)
where
    plt.source in (3,33)  -- c来源
    and plt.state in (1,2,3,4)
group by 2
;

