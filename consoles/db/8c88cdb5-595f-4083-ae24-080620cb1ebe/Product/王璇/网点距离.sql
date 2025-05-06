select
    t.*
    ,st_distance_sphere(point(ss.lng, ss.lat), point(ss2.lng, ss2.lat)) 网点之间距离
from tmpale.tmp_th_store_0105 t
left join fle_staging.sys_store ss on ss.name = t.sys_store
left join fle_staging.sys_store ss2 on ss2.name = t.support_store