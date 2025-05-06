# case ft.line_plate_type
#             when 100 then '4W'
#             when 101 then '4WJ'
#             when 102 then 'PH4WFB'
#             when 200 then '6W5.5'
#             when 201 then '6W6.5'
#             when 203 then '6W7.2'
#             when 204 then 'PH6W'
#             when 205 then 'PH6WF'
#             when 210 then '6W8.8'
#             when 300 then '10W'
#             when 400 then '14W'
#     end 车型


select
    a.车型
#     ,timestampdiff(minute, a.min_scan_time, a.scan_time) as 扫描时长
    ,case
        when timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 5 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 0 then '0-5分钟'
        when timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 10 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 5 then '5-10分钟'
        when timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 20 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 10 then '10-20分钟'
        when timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 30 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 20 then '20-30分钟'
        when timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 40 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 30 then '30-40分钟'
        when timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 50 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 40 then '40-50分钟'
        when timestampdiff(minute, a.min_scan_time,a.max_scan_time) < 60 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 50 then '50-60分钟'
        when timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 60 then '60分钟以上'
    end 时间段
    ,sum(a2.pno_cnt) 包裹量
    ,count(distinct a.proof_id) 班次量
    ,count(distinct a.车牌号) 车辆数
#     ,avg(timestampdiff(minute, a.min_scan_time, a.max_scan_time)) 平均卸车时长
#     a.*
from
    (
        select
            ft.next_store_name 网点
            ,ft.proof_id
            ,ft.proof_plate_number 车牌号
            ,case ft.line_plate_type
                when 100 then '4W'
                when 101 then '4WJ'
                when 102 then 'PH4WFB'
                when 200 then '6W5.5'
                when 201 then '6W6.5'
                when 203 then '6W7.2'
                when 204 then 'PH6W'
                when 205 then 'PH6WF'
                when 210 then '6W8.8'
                when 300 then '10W'
                when 400 then '14W'
            end 车型
#             ,ft.real_arrive_time as 车辆到达时间
#             ,fvp.relation_no
#             ,convert_tz(pr.routed_at, '+00:00', '+07:00') scan_time
#             ,convert_tz(min(pr.routed_at) over (partition by ft.proof_id ), '+00:00', '+07:00') min_scan_time
#             ,count(fvp.relation_no) pno_cnt
#             ,count(pr.routed_at) scan_cnt
# #             ,fvp.relation_no
            ,min(convert_tz(pr.routed_at, '+00:00', '+07:00')) min_scan_time
            ,max(convert_tz(pr.routed_at, '+00:00', '+07:00')) max_scan_time
        from bi_pro.fleet_time ft
        join fle_staging.fleet_van_proof_parcel_detail fvp on fvp.proof_id = ft.proof_id and fvp.relation_category in (1,3) and fvp.state < 3
        left join rot_pro.parcel_route pr on pr.pno = fvp.relation_no and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN' and pr.routed_at > '2024-07-01' and json_extract(pr.extra_value, '$.proofId') = ft.proof_id
        where
            ft.real_arrive_time > '2024-07-20'
            and ft.real_arrive_time < '2024-07-29'
            and ft.arrive_type in (3,5)
            and ft.next_store_name in ('05 LAS_HUB-ลาซาล', '16 Central_HUB-วังน้อย')
            and pr.routed_at is not null
        group by 1,2,3,4
#             and ft.proof_id = 'SAM12JU827'
    ) a
join
    (
        select
            ft.next_store_name 网点
            ,ft.proof_id
            ,ft.proof_plate_number 车牌号
            ,case ft.line_plate_type
                when 100 then '4W'
                when 101 then '4WJ'
                when 102 then 'PH4WFB'
                when 200 then '6W5.5'
                when 201 then '6W6.5'
                when 203 then '6W7.2'
                when 204 then 'PH6W'
                when 205 then 'PH6WF'
                when 210 then '6W8.8'
                when 300 then '10W'
                when 400 then '14W'
            end 车型
            ,ft.real_arrive_time as 车辆到达时间
            ,count(fvp.relation_no) pno_cnt
            ,count(pr.routed_at) scan_cnt
# #             ,fvp.relation_no
#             ,min(convert_tz(pr.routed_at, '+00:00', '+07:00')) min_scan_time
#             ,max(convert_tz(pr.routed_at, '+00:00', '+07:00')) max_scan_time
        from bi_pro.fleet_time ft
        join fle_staging.fleet_van_proof_parcel_detail fvp on fvp.proof_id = ft.proof_id and fvp.relation_category in (1,3) and fvp.state < 3
        left join rot_pro.parcel_route pr on pr.pno = fvp.relation_no and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN' and pr.routed_at > '2024-07-01' and json_extract(pr.extra_value, '$.proofId') = ft.proof_id
        where
            ft.real_arrive_time > '2024-07-20'
            and ft.real_arrive_time < '2024-07-29'
            and ft.arrive_type in (3,5)
            and ft.next_store_name in ('05 LAS_HUB-ลาซาล', '16 Central_HUB-วังน้อย')

        group by 1,2,3,4
    ) a2 on a2.proof_id = a.proof_id
where
    a2.scan_cnt / a2.pno_cnt > 0.95
group by 1
;
-- 装车


select
    a.车型
#     ,a.store_name HUB
#     ,timestampdiff(minute, a.min_scan_time, a.scan_time) as 扫描时长
#     ,avg(timestampdiff(minute, a.min_scan_time, a.max_scan_time)) 平均卸车时长
    ,case
        when timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 5 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 0 then '0-5分钟'
        when timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 10 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 5 then '5-10分钟'
        when timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 20 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 10 then '10-20分钟'
        when timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 30 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 20 then '20-30分钟'
        when timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 40 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 30 then '30-40分钟'
        when timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 50 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 40 then '40-50分钟'
        when timestampdiff(minute, a.min_scan_time,a.max_scan_time) < 60 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 50 then '50-60分钟'
        when timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 60 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 120 then '1-2小时'
        when timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 120 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 180 then '2-3小时'
        when timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 180 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 240 then '3-4小时'
        when timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 240  then '4小时以上'
    end 时间段
    ,count(distinct a.proof_id) 班次量
    ,count(distinct a.proof_plate_number) 车辆数
    ,sum(a.pno_cnt) 包裹量
from
    (

        select
            ft.proof_id
            ,ft.store_name
            ,ft.proof_plate_number
            ,case ft.line_plate_type
                when 100 then '4W'
                when 101 then '4WJ'
                when 102 then 'PH4WFB'
                when 200 then '6W5.5'
                when 201 then '6W6.5'
                when 203 then '6W7.2'
                when 204 then 'PH6W'
                when 205 then 'PH6WF'
                when 210 then '6W8.8'
                when 300 then '10W'
                when 400 then '14W'
            end 车型
            ,count(distinct fvp.relation_no) pno_cnt
            ,min(pr.routed_at) min_scan_time
            ,max(pr.routed_at) max_scan_time
#             ,convert_tz(pr.routed_at, '+00:00', '+07:00') scan_time
#             ,convert_tz(min(pr.routed_at) over (partition by ft.proof_id ), '+00:00', '+07:00') min_scan_time
        from bi_pro.fleet_time ft
        join fle_staging.fleet_van_proof_parcel_detail fvp on fvp.proof_id = ft.proof_id and fvp.relation_category in (1,3) and fvp.state < 3
        left join rot_pro.parcel_route pr on pr.pno = fvp.relation_no and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN' and pr.routed_at > '2024-07-01' and json_extract(pr.extra_value, '$.proofId') = ft.proof_id
        where
            ft.real_leave_time > '2024-07-20'
            and ft.real_leave_time < '2024-07-29'
            and ft.arrive_type in (3,5)
            and ft.store_name in ('05 LAS_HUB-ลาซาล', '16 Central_HUB-วังน้อย')
            and pr.routed_at is not null
        group by 1,2,3,4
           -- and ft.proof_id = 'SAM12KFY18'
    ) a
group by 1,2
;

-- 明细



;


select
    a.*
    ,a2.pno_cnt 包裹量
#     ,timestampdiff(minute, a.min_scan_time, a.scan_time) as 扫描时长
#     ,case
#         when timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 5 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 0 then '0-5分钟'
#         when timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 10 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 5 then '5-10分钟'
#         when timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 20 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 10 then '10-20分钟'
#         when timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 30 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 20 then '20-30分钟'
#         when timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 40 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 30 then '30-40分钟'
#         when timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 50 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 40 then '40-50分钟'
#         when timestampdiff(minute, a.min_scan_time,a.max_scan_time) < 60 and timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 50 then '50-60分钟'
#         when timestampdiff(minute, a.min_scan_time, a.max_scan_time) >= 60 then '60分钟以上'
#     end 时间段
#     ,sum(a2.pno_cnt) 包裹量
#     ,count(distinct a.proof_id) 班次量
#     ,count(distinct a.车牌号) 车辆数
#     ,avg(timestampdiff(minute, a.min_scan_time, a.scan_time)) 平均卸车时长
#     a.*
from
    (
        select
            ft.next_store_name 网点
            ,ft.proof_id
            ,ft.proof_plate_number 车牌号
            ,case ft.line_plate_type
                when 100 then '4W'
                when 101 then '4WJ'
                when 102 then 'PH4WFB'
                when 200 then '6W5.5'
                when 201 then '6W6.5'
                when 203 then '6W7.2'
                when 204 then 'PH6W'
                when 205 then 'PH6WF'
                when 210 then '6W8.8'
                when 300 then '10W'
                when 400 then '14W'
            end 车型
#             ,ft.real_arrive_time as 车辆到达时间
#             ,fvp.relation_no
#             ,convert_tz(pr.routed_at, '+00:00', '+07:00') scan_time
#             ,convert_tz(min(pr.routed_at) over (partition by ft.proof_id ), '+00:00', '+07:00') min_scan_time
#             ,count(fvp.relation_no) pno_cnt
#             ,count(pr.routed_at) scan_cnt
# #             ,fvp.relation_no
            ,count(distinct coalesce(fvp.pack_no, fvp.relation_no)) scan_pack_cnt
            ,min(convert_tz(pr.routed_at, '+00:00', '+07:00')) min_scan_time
            ,max(convert_tz(pr.routed_at, '+00:00', '+07:00')) max_scan_time
        from bi_pro.fleet_time ft
        join fle_staging.fleet_van_proof_parcel_detail fvp on fvp.proof_id = ft.proof_id and fvp.relation_category in (1,3) and fvp.state < 3
        left join rot_pro.parcel_route pr on pr.pno = fvp.relation_no and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN' and pr.routed_at > '2024-07-01' and json_extract(pr.extra_value, '$.proofId') = ft.proof_id
        where
            ft.real_arrive_time > '2024-07-20'
            and ft.real_arrive_time < '2024-07-29'
            and ft.arrive_type in (3,5)
            and ft.next_store_name in ('05 LAS_HUB-ลาซาล', '16 Central_HUB-วังน้อย')
            and pr.routed_at is not null
        group by 1,2,3,4
#             and ft.proof_id = 'SAM12JU827'
    ) a
join
    (
        select
            ft.next_store_name 网点
            ,ft.proof_id
            ,ft.proof_plate_number 车牌号
            ,case ft.line_plate_type
                when 100 then '4W'
                when 101 then '4WJ'
                when 102 then 'PH4WFB'
                when 200 then '6W5.5'
                when 201 then '6W6.5'
                when 203 then '6W7.2'
                when 204 then 'PH6W'
                when 205 then 'PH6WF'
                when 210 then '6W8.8'
                when 300 then '10W'
                when 400 then '14W'
            end 车型
            ,ft.real_arrive_time as 车辆到达时间
            ,count(fvp.relation_no) pno_cnt
            ,count(pr.routed_at) scan_cnt
# #             ,fvp.relation_no
#             ,min(convert_tz(pr.routed_at, '+00:00', '+07:00')) min_scan_time
#             ,max(convert_tz(pr.routed_at, '+00:00', '+07:00')) max_scan_time
        from bi_pro.fleet_time ft
        join fle_staging.fleet_van_proof_parcel_detail fvp on fvp.proof_id = ft.proof_id and fvp.relation_category in (1,3) and fvp.state < 3
        left join rot_pro.parcel_route pr on pr.pno = fvp.relation_no and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN' and pr.routed_at > '2024-07-01' and json_extract(pr.extra_value, '$.proofId') = ft.proof_id
        where
            ft.real_arrive_time > '2024-07-20'
            and ft.real_arrive_time < '2024-07-29'
            and ft.arrive_type in (3,5)
            and ft.next_store_name in ('05 LAS_HUB-ลาซาล', '16 Central_HUB-วังน้อย')

        group by 1,2,3,4
    ) a2 on a2.proof_id = a.proof_id
where
    a2.scan_cnt / a2.pno_cnt > 0.95
    and timestampdiff(minute, a.min_scan_time, a.max_scan_time) < 5
# group by 1,2

;


-- KKC12GK690


select
    ft.next_store_name 网点
    ,ft.proof_id  出车凭证
    ,ft.proof_plate_number 车牌号
    ,case ft.line_plate_type
        when 100 then '4W'
        when 101 then '4WJ'
        when 102 then 'PH4WFB'
        when 200 then '6W5.5'
        when 201 then '6W6.5'
        when 203 then '6W7.2'
        when 204 then 'PH6W'
        when 205 then 'PH6WF'
        when 210 then '6W8.8'
        when 300 then '10W'
        when 400 then '14W'
    end 车型
#             ,ft.real_arrive_time as 车辆到达时间
    ,fvp.relation_no 单号
    ,fvp.pack_no 集包号
    ,pr.staff_info_id 操作员工
    ,convert_tz(pr.routed_at, '+00:00', '+07:00') 扫描时间
#             ,convert_tz(min(pr.routed_at) over (partition by ft.proof_id ), '+00:00', '+07:00') min_scan_time
#             ,count(fvp.relation_no) pno_cnt
#             ,count(pr.routed_at) scan_cnt
# #             ,fvp.relation_no
#     ,min(convert_tz(pr.routed_at, '+00:00', '+07:00')) min_scan_time
#     ,max(convert_tz(pr.routed_at, '+00:00', '+07:00')) max_scan_time
from bi_pro.fleet_time ft
join fle_staging.fleet_van_proof_parcel_detail fvp on fvp.proof_id = ft.proof_id and fvp.relation_category in (1,3) and fvp.state < 3
left join rot_pro.parcel_route pr on pr.pno = fvp.relation_no and pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN' and pr.routed_at > '2024-07-01' and json_extract(pr.extra_value, '$.proofId') = ft.proof_id
where
    ft.real_arrive_time > '2024-07-20'
    and ft.real_arrive_time < '2024-07-29'
    and ft.arrive_type in (3,5)
    and ft.next_store_name in ('05 LAS_HUB-ลาซาล', '16 Central_HUB-วังน้อย')
    and pr.routed_at is not null
    and ft.proof_id in ('KKC12JPV36' )


;




with t as
    (
        select
            a.*
        from
            (
                select
                    pssn.pno
                    ,pssn.store_name 包裹到达网点
                    ,pssn.arrival_pack_no 包裹网点到件入仓集包号
                    ,p2.store_name as 上游HUB
                    ,p2.store_id
                    ,ddd.CN_element 包裹网点第一条有效路由动作
                    ,convert_tz(pssn.arrived_at, '+00:00', '+07:00') 包裹网点到件入仓时间
                    ,convert_tz(pssn.first_valid_routed_at, '+00:00', '+07:00') 包裹网点第一条有效路由动作时间
                    ,p3.van_out_proof_id
                    ,row_number() over (partition by p2.pno order by p3.shipped_at) rk
                from dw_dmd.parcel_store_stage_new pssn
                left join dwm.dwd_dim_dict ddd on ddd.element = pssn.first_valid_route_action and ddd.db = 'rot_pro' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
                join dw_dmd.parcel_store_stage_new p2 on p2.pno = pssn.pno and p2.valid_store_order = pssn.valid_store_order - 1 and p2.created_at > '2024-07-19'
                left join dw_dmd.parcel_store_stage_new p3 on p3.store_id = p2.store_id  and p3.next_store_id = pssn.store_id and p3.shipped_at > date_add(p2.arrived_at, interval 2 hour) and p3.shipped_at < pssn.first_valid_routed_at  and p3.created_at > '2024-07-19' and p3.van_out_proof_id is not null-- hub到仓1小时候
                where
                    pssn.first_valid_routed_at > '2024-07-28 17:00:00'
                    and pssn.first_valid_routed_at < '2024-07-29 17:00:00'
                    and pssn.valid_store_order > 1
                    and p2.store_category in  (8,12)
                    and p2.shipped_at is null
                    and p2.arrived_at is not null
                    and pssn.first_valid_route_action = 'ARRIVAL_WAREHOUSE_SCAN'
            ) a
        where
            a.rk = 1
    )

select
    t1.*
    ,a.staff_info_id
    ,a.scan_cnt 责任占比
#     ,a.store_id hub_id
#     ,a.routed_date
from t t1
left join
    (
        select
            a.van_out_proof_id
            ,a.staff_info_id
            ,a.routed_date
            ,a.store_id
            ,1 / count(a.staff_info_id) over (partition by a.van_out_proof_id) scan_cnt
        from
            (
                select
                    distinct
                    t1.van_out_proof_id
                    ,pr.staff_info_id
                    ,pr.store_id
                    ,pr.store_name
                    ,date(convert_tz(pr.routed_at, '+00:00', '+07:00')) routed_date
                from rot_pro.parcel_route pr
                join t t1 on t1.store_id = pr.store_id and  json_extract(pr.extra_value, '$.proofId') = t1.van_out_proof_id
                where
                    pr.routed_at > '2024-07-26 17:00:00'
                    and pr.route_action = 'SHIPMENT_WAREHOUSE_SCAN'
            ) a
    ) a on a.van_out_proof_id = t1.van_out_proof_id
