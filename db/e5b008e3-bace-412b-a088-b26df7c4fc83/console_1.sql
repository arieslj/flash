with t as
(
    select
        hsi.staff_info_id
        ,max(hst.stat_date) change_date
    from ph_bi.hr_staff_info hsi
    join ph_bi.hr_staff_transfer hst on hst.staff_info_id = hsi.staff_info_id and hst.job_title = 1000
    where
        hsi.job_title = 110 -- van
        and hsi.state = 1
    group by 1
)
select
    t1.staff_info_id
    ,t1.change_date bike转van日期
    ,t1.change_date 转职日期
    ,a1.mileage_date 转职后第一天上班日期
    ,a1.in_work_pic 转职后第一天上班照片
    ,a1.out_work_pic 转职后第一天下班照片
    ,a2.mileage_date 最近一天上班日期
    ,a2.in_work_pic 最近一天上班照片
    ,a2.out_work_pic 最近一天下班照片
from t t1
left join
    (
        select
            smr.staff_info_id
            ,smr.mileage_date
            ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa.object_key) in_work_pic
            ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa2.object_key) out_work_pic
            ,row_number() over (partition by smr.staff_info_id order by smr.mileage_date) rk
        from ph_backyard.staff_mileage_record smr
        join t t1 on smr.staff_info_id = t1.staff_info_id and smr.mileage_date > change_date
        left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = smr.id and left(sa.object_key, 26) = 'staffMileageWorkRecord/SMI' -- 上班里程
        left join ph_backyard.sys_attachment sa2 on sa2.oss_bucket_key = smr.id and left(sa2.object_key, 26) = 'staffMileageWorkRecord/EMI' -- 下班里程
    ) a1 on a1.staff_info_id = t1.staff_info_id and a1.rk = 1
left join
    (
        select
            smr.staff_info_id
            ,smr.mileage_date
            ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa.object_key) in_work_pic
            ,concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/',sa2.object_key) out_work_pic
            ,row_number() over (partition by smr.staff_info_id order by smr.mileage_date desc) rk
        from ph_backyard.staff_mileage_record smr
        join t t1 on smr.staff_info_id = t1.staff_info_id and smr.mileage_date < curdate()
        left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = smr.id and left(sa.object_key, 26) = 'staffMileageWorkRecord/SMI' -- 上班里程
        left join ph_backyard.sys_attachment sa2 on sa2.oss_bucket_key = smr.id and left(sa2.object_key, 26) = 'staffMileageWorkRecord/EMI' -- 下班里程
    ) a2 on a2.staff_info_id = t1.staff_info_id and a2.rk = 1

;
# select left(sa.object_key,26) from ph_backyard.sys_attachment sa where  sa.id = 'f4466fd8fac9de316946d9d0a64340c1'