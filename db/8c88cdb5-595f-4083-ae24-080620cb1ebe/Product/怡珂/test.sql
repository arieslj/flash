select
    pi.pno
    ,pi.ticket_delivery_staff_lng 妥投经度
    ,pi.ticket_delivery_staff_lat 妥投纬度
    ,ss.lng 妥投网点经度
    ,ss.lat  妥投网点纬度
    ,st_distance_sphere(point(pi.ticket_delivery_staff_lng, pi.ticket_delivery_staff_lat), point(ss.lng, ss.lat)) 距离
from fle_staging.parcel_info pi
left join fle_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
where
    pi.pno in ('TH670153D48E9G','TH030253FGBB9I','TH011853NHS89A1','TH030453DK2U9E','TH190753HPJ77A1','TH014552TZC11C','THT0403Q2YCP3Z','TH2004530VEZ8B','TH200453CFEW2B','THT0108Q1HWV4Z','TH040553H2JW5D','TH011853CY2F7A1','TH030253GYFG6I','TH670153MEPJ8G','THT2506PY5BN8Z','TH250653Q8JT4D','THT0109PX19W2Z','TH020553JDBP3B','TH040653NKWF8B1','TH200453JPTS9B5','TH020351TSZG5A','TH020652VJKQ9A','TH020553JFDY6B','TH380153FWYN9D','TH040653PVWY7B1','TH010853PPS87A1','THT0302Q1ZGX0Z','TH380153G4YW5A','TH020553J1HX6B','THT0406Q2E6S3Z')

;


select
    kp.id client_id
    ,case
        when bc.client_name = 'lazada' then 1
        when bc.client_name = 'shopee' then 2
        when bc.client_name = 'tiktok' then 3
        when bc.client_name = 'shein' then 4
        when bc.client_id is null and cgkr.ka_id is not null then 5
        when bc.client_id is null and cgkr.ka_id is null then 6
    end client_type
from fle_staging.ka_profile kp
left join dwm.tmp_ex_big_clients_id_detail bc on bc.client_id = kp.id
left join fle_staging.customer_group_ka_relation cgkr on cgkr.ka_id = kp.id
group by 1,2

union all

select
#     ui.id client_id
#     ,'7' client_type
    count(1)
from fle_staging.user_info ui

;


select
    pci.client_id
    ,pci.client_type
from bi_center.parcel_complaint_inquiry pci
where
    pci.created_at > date_sub(curdate(), interval 1 year)
group by 1,2


;



select
    di.pno
    ,di.diff_marker_category
    ,cdt.*
from fle_staging.customer_diff_ticket cdt
left join fle_staging.diff_info di on di.id = cdt.diff_info_id
where
    cdt.client_id in ('AA0386','AA0427','AA0569','AA0574','AA0612','AA0606','AA0657','AA0707','AA0731','AA0771','AA0794','AA0838')
    and cdt.created_at > '2025-03-12 17:00:00'


;


select
    fvppd.proof_id
    ,fvp.van_line_name
    ,fvppd.store_name
    ,fvppd.next_store_name
    ,count(fvppd.relation_no) cnt
from fle_staging.fleet_van_proof_parcel_detail fvppd
left join fle_staging.fleet_van_proof fvp on fvp.id = fvppd.proof_id
where
    fvppd.relation_category in (1,3)
    and fvppd.state < 3
    and fvppd.proof_id in ('AYU19KZK27', 'BKK19N3863', 'AYU19M6Q36', 'BKK19GYY54')
group by 1,2,3,4
