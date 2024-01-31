select
    sct.created_at
    ,sct.pno
    ,case
        when bc.client_name = 'lazada' then laz.whole_end_date
        when bc.client_name = 'shopee' then shp.end_date
    end  超时日期
    ,case sct.source
        when 1 then '网点提交'
        when 2 then '客户提交'
        when 3 then '系统自动抓取'
    end 来源
    ,bc.client_name
    ,if(pi.returned = 1, '退件', '正向') 超时效类型
from ph_bi.ss_court_task sct
join dwm.dwd_dim_bigClient bc on bc.client_id = sct.client_id and bc.client_name in ('lazada', 'shopee')
left join ph_staging.parcel_info pi on pi.pno = sct.pno
left join dwm.dwd_ex_ph_lazada_pno_period laz on laz.pno = sct.pno
left join dwm.dwd_ex_shopee_lost_pno_period shp on shp.pno = sct.pno
where
    sct.created_at > '2023-12-01'
    and sct.created_at < '2024-01-01'
    and sct.source in (2,3)
#     and sct.state in (2,3,5)
    and (case when bc.client_name = 'lazada' then laz.whole_end_date when bc.client_name ='shopee' then shp.end_date end) > sct.created_at
    and (case when bc.client_name = 'lazada' then laz.whole_end_date when bc.client_name ='shopee' then shp.end_date end) < if(sct.state in (2,3,5), sct.updated_at, now())