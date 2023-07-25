select
    fvp.pack_no
    ,fvp.relation_no pno
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then 'Normal KA'
        when kp.`id` is null then 'GE'
    end as customer_type
    ,pi.cod_amount/100 cod
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) cogs
    ,ddd.EN_element parcel_status
from ph_staging.fleet_van_proof_parcel_detail fvp
left join ph_staging.parcel_info pi on pi.pno = fvp.relation_no
left join ph_staging.order_info oi on oi.pno = pi.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join dwm.dwd_dim_dict ddd on ddd.element = pi.state and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_info' and  ddd.fieldname = 'state'
where
    fvp.pack_no in ('P77609536','P77623309','P77617336','P77609527')