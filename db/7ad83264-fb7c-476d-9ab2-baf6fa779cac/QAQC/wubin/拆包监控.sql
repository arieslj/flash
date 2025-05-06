select
    distinct
    date (convert_tz(pi.unseal_at, '+00:00','+07:00')) 日期
    ,dp.store_name 拆包DC
    ,dp.region_name 拆包片区
    ,dp.piece_name 拆包大区
    ,convert_tz(pi.unseal_store_scan_at, '+00:00','+07:00') 整包到件扫描时间
    ,ss.name '集包DC/hub'
    ,pi.pack_no 集包号
    ,pi.seal_count 集包数量
    ,pi.unseal_count 拆包数量
from ph_staging.pack_info pi
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pi.unseal_store_id and dp.stat_date = date_sub(curdate(), 1)
left join ph_staging.sys_store ss on ss.id = pi.seal_store_id
left join ph_staging.pack_unseal_detail pud on pud.pack_no = pi.pack_no
where
    pud.pack_no is not null
    and pi.unseal_at > date_sub(curdate(), interval 31 hour)
    and pi.unseal_at < date_sub(curdate(), interval 7 hour)
    and pi.state < 4