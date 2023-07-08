select
    tp.ka_warehouse_id
from nl_production.customer_complaint_collects ccc
left join ph_staging.ticket_pickup tp on tp.id = ccc.merge_column
where
    ccc.created_at >= '2023-01-01'
    and ccc.ticket_type = 1
group by 1