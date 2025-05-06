-- 员工账户下单
select
    pi.pno
    ,pi.cod_amount
    ,
from fle_staging.parcel_info pi
join bi_pro.hr_staff_info hsi on hsi.mobile = pi.dst_phone
left join bi_center.parcel_sub ps on ps.pno = pi.pno
where
    hsi.sys_department_id = 4 -- network
    and pi.created_at > date_sub(curdate(), interval 3 month)
    and pi.state in (1,2,3,4,6,7)
    and pi.returned = 0
    and hsi.state = 1
