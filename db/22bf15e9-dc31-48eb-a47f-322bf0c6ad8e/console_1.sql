select
    cdt.state
    ,count(cdt.id)
from fle_staging.customer_diff_ticket cdt
where
    cdt.first_operated_at is not null