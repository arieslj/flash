select
    a.pno
    ,a.job_name
    ,if(sum(a.total) > 0, '有', '无') 是否有推送AMDM
from
    (
        select
            a1.pno
            ,a1.job_name
            ,if(smp.manager_id is not null or smr.manager_id is not null, 1, 0) total
        from
            (
                select
                    a.*
                    ,staff
                from
                    (
                        select
                            t.pno
                            ,hjt.job_name
                            ,replace(replace(replace(json_extract(pcil.extra_info, '$.push_staff_arr'), '"', ''), '[', ''), ']', '') push_staff
                        from bi_center.parcel_complaint_inquiry pci
                        join tmpale.tmp_th_pno_lj_1104 t on t.pno = pci.merge_column
                        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = pci.apology_staff_info_id
                        left join bi_pro.hr_job_title hjt on hjt.id = hsi.job_title
                        left join bi_center.parcel_complaint_inquiry_log pcil on pcil.inquiry_id = pci.id and pcil.type = 3
                    ) a
                lateral view explode(split(a.push_staff, ',')) id as staff
            ) a1
        left join
            (
                select
                    smp.manager_id
                from fle_staging.sys_store ss
                left join fle_staging.sys_manage_piece smp on smp.id = ss.manage_piece
                where
                    ss.state = 1
                    and smp.deleted = 0
            ) smp on smp.manager_id = a1.staff
        left join
            (
                select
                    ss.manager_id
                from fle_staging.sys_store ss
                left join fle_staging.sys_manage_region smr on smr.id = ss.manage_region
                where
                    ss.state = 1
                    and smr.deleted = 0
            ) smr on smr.manager_id = a1.staff
    ) a
group by 1,2