select
    si.id
    ,si.name
from ph_backyard.staff_info si
where
    si.name like '%001'
    and si.name like 'VR%'
    and si.created_at >= '2024-01-01'
;


select
    si.id
    ,si.name
from ph_backyard.staff_info si
where
    si.name like '%00%'
    and si.name like 'VR%'
    and si.created_at >= '2024-01-01'

;

