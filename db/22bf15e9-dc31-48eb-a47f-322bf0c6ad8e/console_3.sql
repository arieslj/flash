select
    ph.print_state
from fle_staging.parcel_headless ph
where
    ph.state != 3
group by 1