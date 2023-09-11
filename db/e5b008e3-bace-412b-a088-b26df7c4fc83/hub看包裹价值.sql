
select
    ppl.replace_pno 输入单号
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,loi.item_name 产品名称
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 物品价值
    ,pi2.cod_amount/100 COD金额
from ph_staging.parcel_pno_log ppl
left join ph_staging.parcel_info pi on pi.pno = ppl.initial_pno
left join ph_staging.parcel_info pi2 on if(pi.returned = 0, pi.pno, pi.customary_pno) = pi2.pno
left join ph_drds.lazada_order_info_d loi on loi.pno = pi2.pno
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_staging.ka_profile kp on kp.id = pi2.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi2.client_id
join tmpale.tmp_ph_pno_lj_0829 t on t.pno = ppl.replace_pno
# where
#     ppl.replace_pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')

union all

select
    pi.pno 输入单号
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as  客户类型
    ,loi.item_name 产品名称
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) 物品价值
    ,pi2.cod_amount/100 COD金额
from ph_staging.parcel_info pi
left join ph_staging.parcel_info pi2 on if(pi.returned = 0, pi.pno, pi.customary_pno) = pi2.pno
left join ph_drds.lazada_order_info_d loi on loi.pno = pi2.pno
left join ph_staging.order_info oi on oi.pno = pi2.pno
left join ph_staging.ka_profile kp on kp.id = pi2.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi2.client_id
join tmpale.tmp_ph_pno_lj_0829 t on t.pno = pi.pno
# where
#     pi.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')