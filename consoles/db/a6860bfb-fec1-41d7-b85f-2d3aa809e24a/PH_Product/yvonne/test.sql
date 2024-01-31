select
    t.task_id
    ,vrv.link_id pno
    ,case pi.state
        when 1 then 'RECEIVED'
        when 2 then 'IN_TRANSIT'
        when 3 then 'DELIVERING'
        when 4 then 'STRANDED'
        when 5 then 'SIGNED'
        when 6 then 'IN_DIFFICULTY'
        when 7 then 'RETURNED'
        when 8 then 'ABNORMAL_CLOSED'
        when 9 then 'CANCEL'
    end status
from nl_production.violation_return_visit vrv
join tmpale.tmp_ph_visit_lj_0112 t on t.task_id = vrv.id
left join ph_staging.parcel_info pi on pi.pno = vrv.link_id
