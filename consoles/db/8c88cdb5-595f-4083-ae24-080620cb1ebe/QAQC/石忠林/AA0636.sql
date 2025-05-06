select
    count(1)
from fle_staging.parcel_info pi
where
    pi.returned = 0
    and pi.state < 9
    and pi.client_id = 'AA0636'
    and pi.created_at > '2024-11-15 17:00:00'
    and pi.created_at < '2024-11-30 17:00:00'