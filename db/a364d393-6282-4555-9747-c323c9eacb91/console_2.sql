select
    *
    ,row_number() over (order by r.uid_nickname) rk
from aries.result_2 r