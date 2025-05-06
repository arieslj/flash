select
    *
from rot_pro.parcel_route pr
where
    pr.routed_at > date_sub(curdate(), interval 2 month )
    and pr.route_action = 'DIFFICULTY_FINISH_INDEMNITY'