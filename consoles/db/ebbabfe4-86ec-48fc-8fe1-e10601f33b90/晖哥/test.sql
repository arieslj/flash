select
    *
from dwm.dwd_my_dc_should_be_delivery ds
where
    ds.p_date = curdate() -- 今日应派
    and ds.should_delevry_type!= '非当日应派'
;