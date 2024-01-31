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