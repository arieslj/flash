select
    *
from ph_staging.store_receivable_bill_detail srb
where
    srb.receivable_type_category = 5
    and srb.state = 0