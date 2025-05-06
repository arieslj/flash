  /*=====================================================================+
    表名称： 2353d_th_hub_incentives_monitor
    功能描述： 泰国分拨激励数据监测

    需求来源：QAQC
    编写人员: 吕杰
    设计日期：2025-01-10
    修改日期:
    修改人员:
    修改原因:
  -----------------------------------------------------------------------
  ---存在问题：
  -----------------------------------------------------------------------
  +=====================================================================*/





with t as
    (
        select
            dor.pno
            ,dor.state
            ,dor.id
            ,dor.store_id
            ,dor.created_at
            ,dor.updated_at
            ,dor.repaired_staff_id
        from fle_staging.diff_operation_record dor
        join fle_staging.diff_info di on di.id = dor.diff_info_id
        where
            dor.created_at > if(day(curdate()) = 1, date_sub(date_sub(curdate(), interval 1 month ), interval 7 hour), date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour))
            and dor.created_at < date_sub(curdate(), interval 7 hour)
    )
select
    ss.name HUB
    ,ph.claim_rate '无头认领率อัตราการลงจุดรับคืน'
    ,ph.claim_sign_rate 认领妥投率อัตราการยืนยันปลายทาง
    ,if(ph.claim_rate > 0.5 and ph.claim_sign_rate > 0.8, 'YES', 'NO') as 无头包裹项目是否达标ผ่านเกณฑ์หรือไม่
    ,if(ph.claim_rate > 0.5 and ph.claim_sign_rate > 0.8, re1.rewards, 0) as 无头件成功上报激励เงินรางวัลการรายงานพัสดุไม่มีลาเบลสำเร็จ
    ,if(ph.claim_rate > 0.5 and ph.claim_sign_rate > 0.8, re2.rewards, 0) as 无头匹配成功激励เงินรางวัลการจับคู่พัสดุไม่มีลาเบลสำเร็จ
    ,a2.修复转运比 修复转运率อัตราการซ่อมแซมแล้วส่งต่อ
    ,a3.二次包装无上报比例 二次包装无上报率อัตราการรายงาน
    ,a2.24小时内修复转运包裹比 24H修复出仓率อัตราซ่อมแซมแล้วส่งออก
    ,if(a2.修复转运比 >= 0.8 and ifnull(a3.二次包装无上报比例, 0) <= 0.1 and a2.24小时内修复转运包裹比 >= 0.9, 'YES', 'NO') as 修复项目是否达标ผ่านเกณฑ์หรือไม่
    ,if(a2.修复转运比 >= 0.8 and ifnull(a3.二次包装无上报比例, 0) <= 0.1 and a2.24小时内修复转运包裹比 >= 0.9, re3.rewards, 0) as 修复项目激励เงินรางวัลซ่อมแซม
    ,if(ph.claim_rate > 0.5 and ph.claim_sign_rate > 0.8, re1.rewards, 0) + if(ph.claim_rate > 0.5 and ph.claim_sign_rate > 0.8, re2.rewards, 0) + if(a2.修复转运比 >= 0.8 and ifnull(a3.二次包装无上报比例, 0) <= 0.1 and a2.24小时内修复转运包裹比 >= 0.9, re3.rewards, 0) as 合计激励รวมเงินรางวัล
from
    (

        select
            ss.id
            ,ss.name
        from fle_staging.sys_store ss
        where
            ss.state = 1
            and ss.category in (8,12)
            and ss.name not in ('28 UTH_BHUB-อุดรธานี','29 UBP_BHUB-อุบลราชธานี','30 YAS_BHUB-ยโสธร','31 BRR_BHUB-บุรีรัมย์','32 SNO_BHUB-สกลนคร','34 LPT_BHUB-ลำปาง','35 CNX_BHUB-เชียงใหม่','36 CEI_BHUB-เชียงราย','39 HDY_BHUB-หาดใหญ่','77 SCB_HUB-บางพลี','Virtual_Hub-SO4')
    ) ss
left join
    (
        select
            ph.submit_store_id
            ,ph.submit_store_name
            ,count(distinct if(ph.state = 2, ph.hno, null)) claim_count
            ,count(distinct if(ph.state = 2, ph.hno, null)) / count(distinct ph.hno) as claim_rate
            ,count(distinct if(ph.state = 2 and pi.state = 5, ph.hno, null)) / count(distinct ph.hno) claim_sign_rate
        from fle_staging.parcel_headless ph
        join fle_staging.sys_store ss on ss.id = ph.submit_store_id and ss.category in (8,12)
        left join fle_staging.parcel_info pi on pi.pno = ph.pno and pi.created_at > date_sub(curdate(), interval 3 month)
        where
            ph.created_at > if(day(curdate()) = 1, date_sub(date_sub(curdate(), interval 1 month ), interval 7 hour), date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour))
            and ph.created_at < date_sub(curdate(), interval 7 hour)
        group by 1,2
    ) ph on ph.submit_store_id = ss.id
left join
    (
        select
            ss.id store_id
            ,ss.name HUB
            ,count(distinct t1.pno) 上报包裹数
            ,count(distinct if(a.pno is not null, t1.pno, null)) 转运包裹数
            ,count(distinct if(a.pno is not null, t1.pno, null)) / count(distinct t1.pno) 修复转运比
            ,count(distinct if(a.diff_hour <= 24 , t1.pno, null)) / count(distinct t1.pno) 24小时内修复转运包裹比
        from t t1
        left join fle_staging.sys_store ss on ss.id = t1.store_id
        left join
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,timestampdiff(hour, t1.created_at, t1.updated_at) diff_hour
                from rot_pro.parcel_route pr
                join
                    (
                        select
                            t1.pno
                            ,t1.store_id
                            ,t1.created_at
                            ,t1.updated_at
                        from t t1
                        where
                            t1.state = 4
                    ) t1 on t1.pno = pr.pno and t1.store_id = pr.store_id
                where
                    pr.routed_at > date_sub(curdate(), interval 3 month)
                    and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            ) a on a.pno = t1.pno
        group by 1,2
    ) a2 on a2.store_id = ss.id
left join
    (
        select
            ss.id
            ,ss.name HUB
            ,count(distinct plt.pno) 破损判责数量
            ,count(distinct if(plt.duty_reasons = 'parcel_lose_duty_damaged_reasons_9', plt.pno, null)) 二次包装无上报判责数量
            ,count(distinct if(plt.duty_reasons = 'parcel_lose_duty_damaged_reasons_9', plt.pno, null)) / count(distinct plt.pno) 二次包装无上报比例
        from bi_pro.parcel_lose_task plt
        join fle_staging.customer_diff_ticket cdt on cdt.id = plt.source_id
        left join fle_staging.diff_info di on di.id = cdt.diff_info_id
        left join fle_staging.sys_store ss on ss.id = di.store_id
        where
            cdt.created_at > if(day(curdate()) = 1, date_sub(date_sub(curdate(), interval 1 month ), interval 7 hour), date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour))
            and cdt.created_at < date_sub(curdate(), interval 7 hour)
            and plt.source = 4
            and plt.state = 6
            and plt.duty_result = 2
        group by 1,2
    ) a3 on a3.id = ss.id
left join
    (
        select
            p2.submit_store_id
            ,sum(p2.sub_reward) as rewards
        from
            (
                select
                        p1.submit_store_id
                        ,p1.submit_staff_id
                        ,least(claim_count * 3, 1000) as sub_reward
                    from
                        (
                            select
                                ph.submit_store_id
                                ,ph.submit_staff_id
                                ,count(distinct ph.hno) claim_count
                            from fle_staging.parcel_headless ph
                            join fle_staging.sys_store ss on ss.id = ph.submit_store_id and ss.category in (8,12)
                            where
                                ph.created_at > if(day(curdate()) = 1, date_sub(date_sub(curdate(), interval 1 month ), interval 7 hour), date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour))
                                and ph.created_at < date_sub(curdate(), interval 7 hour)
                            group by 1,2
                        ) p1
            ) p2
        group by 1
    ) re1 on re1.submit_store_id = ss.id
left join
    (
        select
            p2.submit_store_id
            ,sum(p2.sub_reward) as rewards
        from
            (
                select
                        p1.submit_store_id
                        ,p1.submit_staff_id
                        ,least(claim_count * 7, 1000) as sub_reward
                    from
                        (
                            select
                                ph.submit_store_id
                                ,ph.submit_staff_id
                                ,count(distinct ph.hno) claim_count
                            from fle_staging.parcel_headless ph
                            join fle_staging.sys_store ss on ss.id = ph.submit_store_id and ss.category in (8,12)
                            where
                                ph.created_at > if(day(curdate()) = 1, date_sub(date_sub(curdate(), interval 1 month ), interval 7 hour), date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour))
                                and ph.created_at < date_sub(curdate(), interval 7 hour)
                                and ph.state = 2
                            group by 1,2
                        ) p1
            ) p2
        group by 1
    ) re2 on re2.submit_store_id = ss.id
left join
    (
        select
            a2.store_id
            ,sum(a2.rewards) as rewards
        from
            (
                select
                    a1.repaired_staff_id
                    ,a1.store_id
                    ,least(a1.repaired_count * 3, 1000) as rewards
                from
                    (
                        select
                            pr.store_id
                            ,t1.repaired_staff_id
                            ,count(distinct t1.pno) repaired_count
                        from rot_pro.parcel_route pr
                        join
                            (
                                select
                                    t1.pno
                                    ,t1.store_id
                                    ,t1.repaired_staff_id
                                from t t1
                                where
                                    t1.state = 4
                            ) t1 on t1.pno = pr.pno and t1.store_id = pr.store_id
                        where
                            pr.routed_at > date_sub(curdate(), interval 3 month)
                            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
                        group by 1,2
                    ) a1
            ) a2
        group by 1
    ) re3 on re3.store_id = ss.id
order by 1

;

 -- 修复转运比เทียบ%ซ่อมแซมแล้วส่งต่อ
with t as
    (
        select
            dor.pno
            ,dor.state
            ,dor.id
            ,dor.store_id
            ,dor.created_at
            ,dor.updated_at
            ,dor.repaired_staff_id
        from fle_staging.diff_operation_record dor
        join fle_staging.diff_info di on di.id = dor.diff_info_id
        where
            dor.created_at > if(day(curdate()) = 1, date_sub(date_sub(curdate(), interval 1 month ), interval 7 hour), date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour))
            and dor.created_at < date_sub(curdate(), interval 7 hour)
    )
select
    ss.id HUB_ID
    ,ss.name HUB
    ,count(distinct t1.pno) 上报包裹数จำนวนพัสดุที่รายงาน
    ,count(distinct if(a.pno is not null, t1.pno, null)) 转运包裹数จำนวนพัสดุที่ส่งต่อ
    ,count(distinct if(a.pno is not null, t1.pno, null)) / count(distinct t1.pno) '修复转运比เทียบ%ซ่อมแซมแล้วส่งต่อ'
#     ,count(distinct if(a.diff_hour <= 24 , t1.pno, null)) 24小时内修复转运包裹数
#     ,count(distinct if(a.diff_hour <= 24 , t1.pno, null)) / count(distinct t1.pno) 24小时内修复转运包裹比
from t t1
left join fle_staging.sys_store ss on ss.id = t1.store_id
left join
    (
        select
            pr.pno
            ,pr.store_id
            ,timestampdiff(hour, t1.created_at, t1.updated_at) diff_hour
        from rot_pro.parcel_route pr
        join
            (
                select
                    t1.pno
                    ,t1.store_id
                    ,t1.created_at
                    ,t1.updated_at
                from t t1
                where
                    t1.state = 4
            ) t1 on t1.pno = pr.pno and t1.store_id = pr.store_id
        where
            pr.routed_at > date_sub(curdate(), interval 3 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    ) a on a.pno = t1.pno
group by 1,2

;


-- 二次包装无上报比例เทียบ%ไม่ได้รายงาน
select
    ss.id HUB_ID
    ,ss.name HUB
    ,count(distinct plt.pno) 破损判责数量จำนวนที่พัสดุโดนตัดสินเสียหาย
    ,count(distinct if(plt.duty_reasons = 'parcel_lose_duty_damaged_reasons_9', plt.pno, null)) 二次包装无上报判责数量จำนวนพัสดุที่โดนตัดสินไม่ได้มีการรายงานหลังรีแพ็คพัสดุ
    ,count(distinct if(plt.duty_reasons = 'parcel_lose_duty_damaged_reasons_9', plt.pno, null)) / count(distinct plt.pno) '二次包装无上报比例เทียบ%ไม่ได้มีการรายงานหลังรีแพ็คพัสดุ'
from bi_pro.parcel_lose_task plt
join fle_staging.customer_diff_ticket cdt on cdt.id = plt.source_id
left join fle_staging.diff_info di on di.id = cdt.diff_info_id
left join fle_staging.sys_store ss on ss.id = di.store_id
where
    cdt.created_at > if(day(curdate()) = 1, date_sub(date_sub(curdate(), interval 1 month ), interval 7 hour), date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour))
    and cdt.created_at < date_sub(curdate(), interval 7 hour)
    and plt.source = 4
    and plt.state = 6
    and ss.category in (8,12)
    and plt.duty_result = 2
group by 1,2

;

-- 24小时内修复并发件出仓ซ่อมแซมส่งต่อ24ชม

with t as
    (
        select
            dor.pno
            ,dor.state
            ,dor.id
            ,dor.store_id
            ,dor.created_at
            ,dor.updated_at
            ,dor.repaired_staff_id
        from fle_staging.diff_operation_record dor
        join fle_staging.diff_info di on di.id = dor.diff_info_id
        where
            dor.created_at > if(day(curdate()) = 1, date_sub(date_sub(curdate(), interval 1 month ), interval 7 hour), date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour))
            and dor.created_at < date_sub(curdate(), interval 7 hour)
    )
select
    ss.id HUB_ID
    ,ss.name HUB
    ,count(distinct t1.pno) 上报包裹数จำนวนพัสดุที่รายงาน
#     ,count(distinct if(a.pno is not null, t1.pno, null)) 转运包裹数จำนวนพัสดุที่ส่งต่อ
#     ,count(distinct if(a.pno is not null, t1.pno, null)) / count(distinct t1.pno) '修复转运比เทียบ%ซ่อมแซมแล้วส่งต่อ'
    ,count(distinct if(a.diff_hour <= 24 , t1.pno, null)) 转运包裹数จำนวนพัสดุที่ส่งต่อ
    ,count(distinct if(a.diff_hour <= 24 , t1.pno, null)) / count(distinct t1.pno) '修复转运比เทียบ%ซ่อมแซมแล้วส่งต่อ'
from t t1
left join fle_staging.sys_store ss on ss.id = t1.store_id
left join
    (
        select
            pr.pno
            ,pr.store_id
            ,timestampdiff(hour, t1.created_at, t1.updated_at) diff_hour
        from rot_pro.parcel_route pr
        join
            (
                select
                    t1.pno
                    ,t1.store_id
                    ,t1.created_at
                    ,t1.updated_at
                from t t1
                where
                    t1.state = 4
            ) t1 on t1.pno = pr.pno and t1.store_id = pr.store_id
        where
            pr.routed_at > date_sub(curdate(), interval 3 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    ) a on a.pno = t1.pno
group by 1,2
;


select
    ph.submit_store_id HUB_ID
    ,ph.submit_store_name HUB
    ,count(distinct if(ph.state = 2, ph.hno, null)) 认领无头件数จำนวนพัสดุไม่มีลาเบลที่รับคืน
    ,count(distinct if(ph.state = 2 and pi.state = 5, ph.hno, null)) 妥投无头件数จำนวนพัสดุไม่มีลาเบลที่ยืนยันปลายทาง
    ,count(distinct if(ph.state = 2 and pi.state = 5, ph.hno, null)) / count(distinct if(ph.state = 2, ph.hno, null)) '妥投比例เทียบ%การรับคืน'
from fle_staging.parcel_headless ph
join fle_staging.sys_store ss on ss.id = ph.submit_store_id and ss.category in (8,12)
left join fle_staging.parcel_info pi on pi.pno = ph.pno and pi.created_at > date_sub(curdate(), interval 3 month)
where
    ph.created_at > if(day(curdate()) = 1, date_sub(date_sub(curdate(), interval 1 month ), interval 7 hour), date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour))
    and ph.created_at < date_sub(curdate(), interval 7 hour)
group by 1,2


;
-- พนักงานที่รายงานซ่อมแซม



with t as
    (
        select
            dor.pno
            ,dor.state
            ,dor.id
            ,dor.store_id
            ,ss2.name
            ,dor.created_at
            ,dor.updated_at
            ,dor.staff_id
            ,dor.repaired_staff_id
        from fle_staging.diff_operation_record dor
        join fle_staging.diff_info di on di.id = dor.diff_info_id
        left join fle_staging.sys_store ss2 on ss2.id = dor.store_id
        where
            dor.created_at > if(day(curdate()) = 1, date_sub(date_sub(curdate(), interval 1 month ), interval 7 hour), date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour))
            and dor.created_at < date_sub(curdate(), interval 7 hour)
    )
select
    t1.pno 修复上报且已转运的运单号เลขพัสดุที่ซ่อมแซมรายงานและส่งต่อแล้ว
    ,t1.staff_id 修复上报人พนักงานที่รายงานซ่อมแซม
    ,t1.name HUB
    ,convert_tz(t1.updated_at, '+00:00', '+07:00') 修复时间เวลาที่ซ่อมแซม
    ,min(convert_tz(a.routed_at, '+00:00', '+07:00')) 出仓时间เวลาที่ออกคลัง
from t t1
left join fle_staging.sys_store ss on ss.id = t1.store_id
join
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.routed_at
            ,timestampdiff(hour, t1.created_at, t1.updated_at) diff_hour
        from rot_pro.parcel_route pr
        join
            (
                select
                    t1.pno
                    ,t1.store_id
                    ,t1.created_at
                    ,t1.updated_at
                from t t1
                where
                    t1.state = 4
            ) t1 on t1.pno = pr.pno and t1.store_id = pr.store_id
        where
            pr.routed_at > date_sub(curdate(), interval 3 month)
            and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
    ) a on a.pno = t1.pno
group by 1,2,3,4
;
-- เลขพัสดุไม่มีลาเบลที่ยืนยันปลายทางแล้ว

select
    ph.submit_store_id HUB_ID
    ,ph.submit_store_name HUB
    ,ph.pno 已妥投的无头包裹运单号เลขพัสดุไม่มีลาเบลที่ยืนยันปลายทางแล้ว
    ,ph.submit_staff_id 上报人พนักงานที่รายงาน
    ,ph.claim_staff_id 认领人พนักงานที่รับคืน
    ,ph.created_at 上报时间เวลาที่รายงาน
    ,convert_tz(ph.claim_at, '+00:00', '+07:00') 认领时间เวลาที่รับคืน
from fle_staging.parcel_headless ph
join fle_staging.sys_store ss on ss.id = ph.submit_store_id and ss.category in (8,12)
join fle_staging.parcel_info pi on pi.pno = ph.pno and pi.created_at > date_sub(curdate(), interval 3 month)
where
    ph.created_at > if(day(curdate()) = 1, date_sub(date_sub(curdate(), interval 1 month ), interval 7 hour), date_sub(date_format(curdate(), '%Y-%m-01'), interval 7 hour))
    and ph.created_at < date_sub(curdate(), interval 7 hour)
    and pi.state = 5
    and ph.state = 2
