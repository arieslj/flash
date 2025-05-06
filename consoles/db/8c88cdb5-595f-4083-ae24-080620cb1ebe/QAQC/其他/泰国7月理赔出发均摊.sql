with t as
    (
        select
            plt.pno
            ,plt.id lose_id
            ,pct.id claim_id
            ,plt.updated_at lose_updated_at
            ,plt.duty_type
            ,pct.updated_at claim_updated_at
            ,plt.last_valid_routed_at
            ,ddd.CN_element last_valid_action_cn
            ,date(plt.last_valid_routed_at) last_valid_date
        from bi_pro.parcel_lose_task plt
        join bi_pro.parcel_claim_task pct on pct.lose_task_id = plt.id
        left join dwm.dwd_dim_dict ddd on ddd.element = plt.last_valid_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= '2024-09-01'
            and plt.updated_at < '2024-10-01'
            and pct.created_at > '2024-08-01'
            and pct.state = 6
    )
, plr as
    (
        select
            distinct
            t1.lose_id
            ,t1.last_valid_date
            ,plr.store_id
            ,dt.store_name
            ,dt.store_category
            ,dt.piece_name
            ,dt.region_name
        from bi_pro.parcel_lose_responsible plr
        join t t1 on t1.lose_id = plr.lose_task_id
        join dwm.dim_th_sys_store_rd dt on dt.store_id = plr.store_id and dt.stat_date = t1.last_valid_date
        where
            plr.created_at > '2024-08-01'
    )
, am as
    (
        select
            smr.id
            ,smr.name
            ,smr.manager_id
            ,rvi.created_at
            ,lead(smr.created_at, 1) over (partition by smr.id order by smr.created_at) next_created_at
            ,min(smr.created_at) over (partition by smr.id) min_created_at
            ,rvi.after_object
            ,rvi.before_object
            ,row_number() over (partition by smr.id order by smr.created_at) rk
        from fle_staging.sys_manage_region smr
        join
            (
                select plr.region_name from plr group by 1
            ) s2 on smr.name = s2.region_name
        join fle_staging.record_version_info rvi on rvi.object_id = smr.id and rvi.object_category = 'sys_manage_region' and rvi.event in ('UPDATED', 'CREATED')
        where
            smr.deleted = 0
    )
, dm as
    (
        select
            smp.id
            ,smp.manager_id
            ,rvi.created_at
            ,lead(smp.created_at, 1) over (partition by smp.id order by smp.created_at) next_created_at
            ,min(smp.created_at) over (partition by smp.id) min_created_at
            ,rvi.after_object
            ,rvi.before_object
            ,row_number() over (partition by smp.id order by smp.created_at) rk
        from fle_staging.sys_manage_piece smp
        join
            (
                select plr.piece_name from plr group by 1
            ) s2 on smp.name = s2.piece_name
        left join fle_staging.record_version_info rvi on rvi.object_id = smp.id and rvi.object_category in ('sys_manage_piece', 'sys_manage_price') and rvi.event in ('UPDATED', 'CREATED')
        where
            smp.deleted = 0
    )
select
    t1.pno
    ,t1.lose_updated_at 判责日期
    ,case t1.duty_type
        when 1 then '快递员100%套餐'
        when 2 then '仓9主1套餐(仓管90%主管10%)'
        when 3 then '仓9主1套餐(仓管90%主管10%)'
        when 4 then '双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
        when 5 then '快递员721套餐(快递员70%仓管20%主管10%)'
        when 6 then '仓管721套餐(仓管70%快递员20%主管10%)'
        when 8 then 'LH全责（LH100%）'
        when 7 then '其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
        when 9 then '加盟商套餐'
        when 10 then '双黄套餐(计数网点仓管40%计数网点主管10%对接分拨仓管40%对接分拨主管10%)'
        when 19 then '双黄套餐(计数网点仓管40%计数网点主管10%对接分拨仓管40%对接分拨主管10%)'
        when 20 then  '加盟商双黄套餐（加盟商50%网点仓管45%主管5%）'
        when 21 then '仓7主3套餐(仓管70%主管30%)'
    end 判责套餐
    ,pl.store_name 责任网点
    ,pl.region_name 大区
    ,pl.piece_name 片区
    ,case pl.store_category
        when 1 then 'SP'
        when 2 then 'DC'
        when 4 then 'SHOP'
        when 5 then 'SHOP'
        when 6 then 'FH'
        when 7 then 'SHOP'
        when 8 then 'Hub'
        when 9 then 'Onsite'
        when 10 then 'BDC'
        when 11 then 'fulfillment'
        when 12 then 'B-HUB'
        when 13 then 'CDC'
        when 14 then 'PDC'
    end 网点类型
    ,t1.claim_updated_at 理赔日期
    ,pcn.claim_money 理赔金额
    ,t1.last_valid_action_cn 最后有效路由
    ,t1.last_valid_routed_at 最后有效路由日期
    ,a1.region_manager_id AM_ID
    ,a1.staff_state AM在职状态
    ,pcn.claim_money * 0.05 AM处罚金额
    ,p1.piece_manager_id DM_ID
    ,p1.staff_state DM在职状态
    ,pcn.claim_money * 0.05 PM处罚金额
    ,ds.store_manager_id 主管ID
    ,pcn.claim_money * 0.1 主管处罚金额
    ,ds2.store_manager_id 副主管ID
    ,pcn.claim_money * 0.1 副主管处罚金额
    ,dc.store_dco_id 仓管ID
    ,pcn.claim_money * 0.1 仓管处罚金额
from t t1
left join plr pl on pl.lose_id = t1.lose_id
left join
    (
        select
            t1.claim_id
            ,replace(json_extract(pcn.`neg_result`,'$.money'),'\"','') claim_money
            ,row_number() over (partition by pcn.`task_id` order by pcn.`created_at` DESC ) rn
        from bi_pro.parcel_claim_negotiation pcn
        join t t1 on t1.claim_id = pcn.task_id
        where
            pcn.created_at > '2024-08-01'
    ) pcn on pcn.claim_id = t1.claim_id and pcn.rn = 1
left join
    (
        select
            a1.lose_id
            ,a1.store_id
            ,a1.region_manager_id
            ,if(ad.staff_info_id is not null, 'y', 'n') att_is_not
            ,case
                when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
                when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
                when hsi.`state`=2 then '离职'
                when hsi.`state`=3 then '停职'
            end as staff_state
        from
            (
                select
                    p1.lose_id
                    ,p1.store_id
                    ,p1.last_valid_date
                    ,case
                        when a1.name is null and p1.last_valid_date < a2.created_at then json_extract(a2.before_object, '$.managerId')
                        when a1.name is not null then json_extract(a1.after_object, '$.managerId')
                        when a1.name is null and a2.name is null then smr.manager_id
                    end region_manager_id
                from plr p1
                left join fle_staging.sys_manage_region smr on smr.name = p1.region_name
                left join am a1 on a1.name = p1.region_name and a1.created_at  <= p1.last_valid_date and coalesce(a1.next_created_at, now()) > p1.last_valid_date
                left join am a2 on a2.name = p1.region_name and a2.rk = 1
            ) a1
        left join bi_pro.attendance_data_v2 ad on a1.region_manager_id = ad.staff_info_id and ad.stat_date = a1.last_valid_date
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = a1.region_manager_id
        where
            ad.attendance_end_at is not null
            or ad.attendance_started_at is not null
    ) a1 on a1.lose_id = t1.lose_id and a1.store_id = pl.store_id
left join
    (
        select
            a1.lose_id
            ,a1.store_id
            ,a1.piece_manager_id
            ,if(ad.staff_info_id is not null, 'y', 'n') att_is_not
            ,case
                when hsi.`state`= 1 and hsi.`wait_leave_state`=0 then '在职'
                when hsi.`state`= 1 and hsi.`wait_leave_state`=1 then '待离职'
                when hsi.`state`= 2 then '离职'
                when hsi.`state`= 3 then '停职'
            end as staff_state
        from
            (
                select
                    p1.lose_id
                    ,p1.store_id
                    ,p1.last_valid_date
                    ,case
                        when a1.name is null and p1.last_valid_date < a2.created_at then json_extract(a2.before_object, '$.managerId')
                        when a1.name is not null then json_extract(a1.after_object, '$.managerId')
                        when a1.name is null and a2.name is null then smp.manager_id
                    end piece_manager_id
                from plr p1
                left join fle_staging.sys_manage_piece  smp on smp.name = p1.piece_name
                left join am a1 on a1.name = p1.piece_name and a1.created_at  <= p1.last_valid_date and coalesce(a1.next_created_at, now()) > p1.last_valid_date
                left join am a2 on a2.name = p1.piece_name and a2.rk = 1
            ) a1
        left join bi_pro.attendance_data_v2 ad on a1.piece_manager_id = ad.staff_info_id and ad.stat_date = a1.last_valid_date
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = a1.piece_manager_id
        where
            ad.attendance_end_at is not null
            or ad.attendance_started_at is not null
    ) p1 on p1.lose_id = t1.lose_id and p1.store_id = pl.store_id
left join
    (
        select
            p1.lose_id
            ,p1.store_id
            ,group_concat(distinct ad.staff_info_id) store_manager_id
        from bi_pro.attendance_data_v2 ad
        join plr p1 on p1.store_id = ad.sys_store_id and ad.stat_date = p1.last_valid_date
        join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1
        where
            ad.job_title = 16
            and ( ad.attendance_started_at is not null or ad.attendance_end_at is not null )
        group by 1,2
    ) ds on ds.lose_id = t1.lose_id and ds.store_id = pl.store_id
left join
    (
        select
            p1.lose_id
            ,p1.store_id
            ,group_concat(distinct ad.staff_info_id) store_manager_id
        from bi_pro.attendance_data_v2 ad
        join plr p1 on p1.store_id = ad.sys_store_id and ad.stat_date = p1.last_valid_date
        join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1
        where
            ad.job_title = 451
            and ( ad.attendance_started_at is not null or ad.attendance_end_at is not null )
        group by 1,2
    ) ds2 on ds2.lose_id = t1.lose_id and ds2.store_id = pl.store_id
left join
    (
        select
            p1.lose_id
            ,p1.store_id
            ,group_concat(distinct ad.staff_info_id) store_dco_id
        from bi_pro.attendance_data_v2 ad
        join plr p1 on p1.store_id = ad.sys_store_id and ad.stat_date = p1.last_valid_date
        join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1
        where
            ad.job_title = 37
            and ( ad.attendance_started_at is not null or ad.attendance_end_at is not null )
        group by 1,2
    ) dc on dc.lose_id = t1.lose_id and dc.store_id = pl.store_id

;






-- 修改定时邮件


with t as
    (
        select
            plt.pno
            ,plt.id lose_id
            ,pct.id claim_id
            ,plt.updated_at lose_updated_at
            ,plt.duty_type
            ,pct.updated_at claim_updated_at
            ,plt.last_valid_routed_at
            ,ddd.CN_element last_valid_action_cn
            ,date(plt.last_valid_routed_at) last_valid_date
        from bi_pro.parcel_lose_task plt
        join bi_pro.parcel_claim_task pct on pct.lose_task_id = plt.id
        left join dwm.dwd_dim_dict ddd on ddd.element = plt.last_valid_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
        where
            plt.state = 6
            and plt.duty_result = 1
            and plt.updated_at >= date_format(date_sub(curdate(),interval 1 month ), '%Y-%m-01')
            and plt.updated_at < date_format(curdate(), '%Y-%m-01')
            and pct.created_at > date_format(date_sub(curdate(),interval 2 month ), '%Y-%m-01')
            and pct.state = 6
    )
, plr as
    (
        select
            distinct
            t1.lose_id
            ,t1.last_valid_date
            ,plr.store_id
            ,dt.store_name
            ,dt.store_category
            ,dt.piece_name
            ,dt.region_name
        from bi_pro.parcel_lose_responsible plr
        join t t1 on t1.lose_id = plr.lose_task_id
        join dwm.dim_th_sys_store_rd dt on dt.store_id = plr.store_id and dt.stat_date = t1.last_valid_date
        where
            plr.created_at > date_format(date_sub(curdate(),interval 2 month ), '%Y-%m-01')
    )
, am as
    (
        select
            smr.id
            ,smr.name
            ,smr.manager_id
            ,rvi.created_at
            ,lead(smr.created_at, 1) over (partition by smr.id order by smr.created_at) next_created_at
            ,min(smr.created_at) over (partition by smr.id) min_created_at
            ,rvi.after_object
            ,rvi.before_object
            ,row_number() over (partition by smr.id order by smr.created_at) rk
        from fle_staging.sys_manage_region smr
        join
            (
                select plr.region_name from plr group by 1
            ) s2 on smr.name = s2.region_name
        join fle_staging.record_version_info rvi on rvi.object_id = smr.id and rvi.object_category = 'sys_manage_region' and rvi.event in ('UPDATED', 'CREATED')
        where
            smr.deleted = 0
    )
, dm as
    (
        select
            smp.id
            ,smp.manager_id
            ,rvi.created_at
            ,lead(smp.created_at, 1) over (partition by smp.id order by smp.created_at) next_created_at
            ,min(smp.created_at) over (partition by smp.id) min_created_at
            ,rvi.after_object
            ,rvi.before_object
            ,row_number() over (partition by smp.id order by smp.created_at) rk
        from fle_staging.sys_manage_piece smp
        join
            (
                select plr.piece_name from plr group by 1
            ) s2 on smp.name = s2.piece_name
        left join fle_staging.record_version_info rvi on rvi.object_id = smp.id and rvi.object_category in ('sys_manage_piece', 'sys_manage_price') and rvi.event in ('UPDATED', 'CREATED')
        where
            smp.deleted = 0
    )
select
    t1.pno
    ,t1.lose_updated_at 判责日期
    ,case t1.duty_type
        when 1 then '快递员100%套餐'
        when 2 then '仓9主1套餐(仓管90%主管10%)'
        when 3 then '仓9主1套餐(仓管90%主管10%)'
        when 4 then '双黄套餐(A网点仓管40%主管10%B网点仓管40%主管10%)'
        when 5 then '快递员721套餐(快递员70%仓管20%主管10%)'
        when 6 then '仓管721套餐(仓管70%快递员20%主管10%)'
        when 8 then 'LH全责（LH100%）'
        when 7 then '其他(仅勾选“该运单的责任人需要特殊处理”时才能使用该项)'
        when 9 then '加盟商套餐'
        when 10 then '双黄套餐(计数网点仓管40%计数网点主管10%对接分拨仓管40%对接分拨主管10%)'
        when 19 then '双黄套餐(计数网点仓管40%计数网点主管10%对接分拨仓管40%对接分拨主管10%)'
        when 20 then  '加盟商双黄套餐（加盟商50%网点仓管45%主管5%）'
        when 21 then '仓7主3套餐(仓管70%主管30%)'
    end 判责套餐
    ,pl.store_name 责任网点
    ,pl.region_name 大区
    ,pl.piece_name 片区
    ,case pl.store_category
        when 1 then 'SP'
        when 2 then 'DC'
        when 4 then 'SHOP'
        when 5 then 'SHOP'
        when 6 then 'FH'
        when 7 then 'SHOP'
        when 8 then 'Hub'
        when 9 then 'Onsite'
        when 10 then 'BDC'
        when 11 then 'fulfillment'
        when 12 then 'B-HUB'
        when 13 then 'CDC'
        when 14 then 'PDC'
    end 网点类型
    ,t1.claim_updated_at 理赔日期
    ,pcn.claim_money 理赔金额
    ,t1.last_valid_action_cn 最后有效路由
    ,t1.last_valid_routed_at 最后有效路由日期
    ,a1.region_manager_id AM_ID
    ,a1.staff_state AM在职状态
    ,pcn.claim_money * 0.05 AM处罚金额
    ,p1.piece_manager_id DM_ID
    ,p1.staff_state DM在职状态
    ,pcn.claim_money * 0.05 PM处罚金额
    ,ds.store_manager_id 主管数
    ,pcn.claim_money * 0.1 主管处罚金额
    ,ds2.store_manager_id 副主管数
    ,pcn.claim_money * 0.1 副主管处罚金额
    ,dc.store_dco_id 仓管数
    ,pcn.claim_money * 0.1 仓管处罚金额
from t t1
left join plr pl on pl.lose_id = t1.lose_id
left join
    (
        select
            t1.claim_id
            ,replace(json_extract(pcn.`neg_result`,'$.money'),'\"','') claim_money
            ,row_number() over (partition by pcn.`task_id` order by pcn.`created_at` DESC ) rn
        from bi_pro.parcel_claim_negotiation pcn
        join t t1 on t1.claim_id = pcn.task_id
        where
            pcn.created_at > date_format(date_sub(curdate(),interval 2 month ), '%Y-%m-01')
    ) pcn on pcn.claim_id = t1.claim_id and pcn.rn = 1
left join
    (
        select
            a1.lose_id
            ,a1.store_id
            ,a1.region_manager_id
            ,if(ad.staff_info_id is not null, 'y', 'n') att_is_not
            ,case
                when hsi.`state`=1 and hsi.`wait_leave_state`=0 then '在职'
                when hsi.`state`=1 and hsi.`wait_leave_state`=1 then '待离职'
                when hsi.`state`=2 then '离职'
                when hsi.`state`=3 then '停职'
            end as staff_state
        from
            (
                select
                    p1.lose_id
                    ,p1.store_id
                    ,p1.last_valid_date
                    ,case
                        when a1.name is null and p1.last_valid_date < a2.created_at then json_extract(a2.before_object, '$.managerId')
                        when a1.name is not null then json_extract(a1.after_object, '$.managerId')
                        when a1.name is null and a2.name is null then smr.manager_id
                    end region_manager_id
                from plr p1
                left join fle_staging.sys_manage_region smr on smr.name = p1.region_name
                left join am a1 on a1.name = p1.region_name and a1.created_at  <= p1.last_valid_date and coalesce(a1.next_created_at, now()) > p1.last_valid_date
                left join am a2 on a2.name = p1.region_name and a2.rk = 1
            ) a1
        left join bi_pro.attendance_data_v2 ad on a1.region_manager_id = ad.staff_info_id and ad.stat_date = a1.last_valid_date
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = a1.region_manager_id
        where
            ad.attendance_end_at is not null
            or ad.attendance_started_at is not null
    ) a1 on a1.lose_id = t1.lose_id and a1.store_id = pl.store_id
left join
    (
        select
            a1.lose_id
            ,a1.store_id
            ,a1.piece_manager_id
            ,if(ad.staff_info_id is not null, 'y', 'n') att_is_not
            ,case
                when hsi.`state`= 1 and hsi.`wait_leave_state`=0 then '在职'
                when hsi.`state`= 1 and hsi.`wait_leave_state`=1 then '待离职'
                when hsi.`state`= 2 then '离职'
                when hsi.`state`= 3 then '停职'
            end as staff_state
        from
            (
                select
                    p1.lose_id
                    ,p1.store_id
                    ,p1.last_valid_date
                    ,case
                        when a1.name is null and p1.last_valid_date < a2.created_at then json_extract(a2.before_object, '$.managerId')
                        when a1.name is not null then json_extract(a1.after_object, '$.managerId')
                        when a1.name is null and a2.name is null then smp.manager_id
                    end piece_manager_id
                from plr p1
                left join fle_staging.sys_manage_piece  smp on smp.name = p1.piece_name
                left join am a1 on a1.name = p1.piece_name and a1.created_at  <= p1.last_valid_date and coalesce(a1.next_created_at, now()) > p1.last_valid_date
                left join am a2 on a2.name = p1.piece_name and a2.rk = 1
            ) a1
        left join bi_pro.attendance_data_v2 ad on a1.piece_manager_id = ad.staff_info_id and ad.stat_date = a1.last_valid_date
        left join bi_pro.hr_staff_info hsi on hsi.staff_info_id = a1.piece_manager_id
        where
            ad.attendance_end_at is not null
            or ad.attendance_started_at is not null
    ) p1 on p1.lose_id = t1.lose_id and p1.store_id = pl.store_id
left join
    (
        select
            p1.lose_id
            ,p1.store_id
            ,group_concat(distinct ad.staff_info_id) store_manager_id
        from bi_pro.attendance_data_v2 ad
        join plr p1 on p1.store_id = ad.sys_store_id and ad.stat_date = p1.last_valid_date
        join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1
        where
            ad.job_title = 16
            and ( ad.attendance_started_at is not null or ad.attendance_end_at is not null )
        group by 1,2
    ) ds on ds.lose_id = t1.lose_id and ds.store_id = pl.store_id
left join
    (
        select
            p1.lose_id
            ,p1.store_id
            ,group_concat(distinct ad.staff_info_id) store_manager_id
        from bi_pro.attendance_data_v2 ad
        join plr p1 on p1.store_id = ad.sys_store_id and ad.stat_date = p1.last_valid_date
        join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1
        where
            ad.job_title = 451
            and ( ad.attendance_started_at is not null or ad.attendance_end_at is not null )
        group by 1,2
    ) ds2 on ds2.lose_id = t1.lose_id and ds2.store_id = pl.store_id
left join
    (
        select
            p1.lose_id
            ,p1.store_id
            ,group_concat(distinct ad.staff_info_id) store_dco_id
        from bi_pro.attendance_data_v2 ad
        join plr p1 on p1.store_id = ad.sys_store_id and ad.stat_date = p1.last_valid_date
        join bi_pro.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1
        where
            ad.job_title = 37
            and ( ad.attendance_started_at is not null or ad.attendance_end_at is not null )
        group by 1,2
    ) dc on dc.lose_id = t1.lose_id and dc.store_id = pl.store_id
where
    t1.duty_type in (2,3,5,6,21)
