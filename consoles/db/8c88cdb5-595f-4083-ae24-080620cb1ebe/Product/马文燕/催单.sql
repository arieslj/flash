select
    ci.pno
    ,case ci.request_sub_type
        when 180 then '催单揽收'
        when 181 then '催单派件'
        when 183 then '催单运输中'
    end 催单类型
    ,pi.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.id is null then '普通ka'
        when kp.`id` is null then '小c'
    end 客户类型
    ,case
        when bc.client_name = 'lazada' then laz.sla_end_date
        when bc.client_name = 'shopee' then sho.end_date
        when bc.client_name = 'tiktok' then tik.end_date
        else null
    end  包裹理论时效
    ,datediff(now(), convert_tz(pi.created_at, '+00:00', '+07:00')) 距离揽收天数
    ,case
        when bc.client_name = 'lazada' and curdate() > laz.sla_end_date then 'y'
        when bc.client_name = 'shopee' and curdate() > sho.end_date then 'y'
        when bc.client_name = 'tiktok' and curdate() > tik.end_date then 'y'
        else null
    end 是否超时效
from fle_staging.customer_issue ci
left join fle_staging.parcel_info pi on pi.pno = ci.pno
left join fle_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pi.client_id
left join dwm.dwd_ex_th_lazada_sla_detail laz on laz.pno = ci.pno
left join dwm.dwd_ex_th_shopee_sla_detail sho on sho.pno = ci.pno
left join dwm.dwd_ex_th_tiktok_sla_detail tik on tik.pno = ci.pno
where
    ci.request_sup_type = 18
    and ci.created_at > date_sub(date_sub(curdate(), interval 2 week ), interval 7 hour)
    and ci.request_sub_type in (181, 183)