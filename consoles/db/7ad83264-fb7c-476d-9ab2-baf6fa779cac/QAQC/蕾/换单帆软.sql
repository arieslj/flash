select
    a1.pno
    ,pcd2.old_value as dst_name
    ,pcd3.old_value as dst_phone
    ,pcd4.old_value as dst_detail_address
    ,ss.name
from
    (
        select
            pcd.record_id
            ,pcd.old_value
            ,pcd.pno
        from ph_staging.parcel_change_detail pcd
        where
            pcd.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')
            and pcd.new_value = 'PH19040F05'
    ) a1
left join ph_staging.parcel_change_detail pcd2 on a1.record_id = pcd2.record_id and pcd2.created_at > date_sub(curdate(), interval 4 month) and pcd2.field_name = 'dst_name'
left join ph_staging.parcel_change_detail pcd3 on a1.record_id = pcd3.record_id and pcd3.created_at > date_sub(curdate(), interval 4 month) and pcd3.field_name = 'dst_phone'
left join ph_staging.parcel_change_detail pcd4 on a1.record_id = pcd4.record_id and pcd4.created_at > date_sub(curdate(), interval 4 month) and pcd4.field_name = 'dst_detail_address'
left join ph_staging.parcel_change_detail pcd5 on a1.record_id = pcd5.record_id and pcd5.created_at > date_sub(curdate(), interval 4 month) and pcd5.field_name = 'dst_post_code'
left join ph_staging.sys_store ss on ss.id = a1.old_value

union

select
    pi.pno
    ,pi.dst_name
    ,pi.dst_phone
    ,pi.dst_detail_address
    ,ss2.name
from ph_staging.parcel_info pi
left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
where
    pi.created_at > date_sub(curdate(), interval 4 month)
    and pi.dst_store_id != 'PH19040F05'
    and pi.pno in ('${SUBSTITUTE(SUBSTITUTE(p2,"\n",","),",","','")}')