select
    pci.merge_column
    ,pci.created_at 询问任务提交时间
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,convert_tz(pi.finished_at, '+00:00', '+07:00') 妥投时间
from bi_center.parcel_complaint_inquiry pci
join bi_pro.abnormal_message am on json_extract(am.extra_info, '$.id') = pci.id
left join fle_staging.ka_profile kp on pci.client_id = kp.id
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = pci.client_id
left join fle_staging.parcel_info pi on pi.pno = pci.merge_column
where
    pci.created_at >= '2024-01-12'
    and pci.created_at < '2024-01-24'
    and json_extract(am.extra_info, '$.src') = 'parcel_complaint_inquiry'
    and am.punish_category = 7