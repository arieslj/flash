with t as
(
    select
        ft.store_id 始发网点ID
        ,ft.store_name 始发网点
        ,case ss.category
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
        end 始发网点类型
        ,ft.next_store_id 目的地网点ID
        ,ft.next_store_name 目的地网点
        ,case ss2.delivery_frequency
        when 1 then '一派'
        when 2 then '二派'
    end '一派/二派'
        ,case ss2.category
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
        end 目的地网点类型
        ,ft.line_name 线路
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
        ,ft.plan_leave_time 计划发车时间
        ,ft.real_leave_time 实际发车时间
        ,ft.plan_arrive_time 计划到达时间
        ,if(date_format(ft.plan_arrive_time, '%H:%i') <= '09:00', 'y', 'n') 是否计划9点前到达
        ,if(date_format(ft.plan_arrive_time, '%H:%i') > '09:00' and date_format(ft.plan_arrive_time, '%H:%i') <= '13:00', 'y', 'n' ) 是否计划9_13点前到达
        ,if(date_format(ft.plan_arrive_time, '%H:%i') > '13:00', 'y', 'n' ) 是否计划13点后到达
        ,ft.real_arrive_time 实际到达时间
        ,ft.sign_time fleet签到时间
        ,ft.parcel_count 包裹数
        ,row_number() over (partition by ft.next_store_name order by ft.plan_arrive_time ) rk
    from bi_pro.fleet_time ft
    left join fle_staging.sys_store ss on ss.id = ft.store_id
    left join fle_staging.sys_store ss2 on ss2.id = ft.next_store_id
    where
        date(ft.plan_arrive_time) >= date_sub(curdate(), interval 15 day)
        and ft.arrive_type in (3,5)
        and ft.deleted = 0
        and ss.category in (8,12)
        and ss2.category in (1,10)
#         and ft.line_mode in (1,4)
)
select
    t1.目的地网点
    ,t1.`一派/二派`
    ,min(date_format(t1.计划到达时间, '%H:%i')) 最早计划到达时间
    ,count(if(t1.是否计划9点前到达 = 'y', t1.线路, null)) 9点前到达车次
    ,sum(if(t1.是否计划9点前到达 = 'y', t1.包裹数, null)) 9点前包裹总量
    ,count(if(t1.是否计划9_13点前到达 = 'y', t1.线路, null)) 9_13点到达车次
    ,sum(if(t1.是否计划9_13点前到达 = 'y', t1.包裹数, null))  9_13点前包裹总量
from t t1
left join t t2 on t2.目的地网点ID = t1.目的地网点ID and t2.rk = 1
where
    t1.`一派/二派` = '一派'
group by 1,2

;



select *
	,row_number() over(partition by tt.始发网点ID,tt.目的地网点ID order by tt.运行里程) rk
	from
	(
		select
		ft1.proof_id
		,ft1.line_name
		,case
		when ft1.line_type in (0,1) and sso.category in (8,12) and sst.category in (8,12) then '干线'
		when ft1.line_type in (0,1) then '支线'
		when ft1.line_type = 2 then '班车'
		when ft1.line_type = 3 then 'FH'
		when ft1.line_type = 4 then 'BTS'
		else ft1.line_type end 车线类型
		,fvt.name 车型
		,if(ft1.line_mode = 2,'DD',if(substring_index(ft1.line_name,'-',-1)='RO','RO','RS')) 线路模式
		,case when (count(ft1.proof_id) over(partition by ft1.proof_id)) > 1 then '串点' else '直发' end 直发串点
		,sso.name 始发网点
		,sso.id 始发网点ID
		,case
		when sso.category = 1 then 'SP'
		when sso.category = 10 then 'BDC'
		when sso.category in (4,5,7) then 'SHOP'
		when sso.category = 6 then 'FH'
		when sso.category = 8 then 'HUB'
		when sso.category = 12 then 'BHUB'
		when sso.category = 11 then 'FFM'
		when sso.category = 9 then 'OS'
		when sso.category = 14 then 'PDC'
		when sso.category = 13 then 'CDC'
		end 始发网点类型
		,case
		when sso.category in (8,12) and sso.id in ('TH02030204','TH05110400','TH02030116','TH05110404','TH05110411','TH02030121','TH02030307','TH05110412','TH02030126') then 'BKK'
		when sso.province_code in ('TH01','TH02','TH03','TH04') then 'BKK'
		else 'UPC' end 始发区域
		,case
		when sso.category in (8,12) and sso.id in ('TH02030204','TH05110400','TH02030116','TH05110404','TH05110411','TH02030121','TH02030307','TH05110412','TH02030126') then 'B'
		when sso.province_code in ('TH01','TH02','TH03','TH04') then 'B'
		when sso.sorting_no in ('B','C') then 'C'
		else sso.sorting_no end 始发分拣大区

		,sst.name 目的地网点
		,sst.id 目的地网点ID
		,case
		when sst.category = 1 then 'SP'
		when sst.category = 10 then 'BDC'
		when sst.category in (4,5,7) then 'SHOP'
		when sst.category = 6 then 'FH'
		when sst.category = 8 then 'HUB'
		when sst.category = 12 then 'BHUB'
		when sst.category = 11 then 'FFM'
		when sst.category = 9 then 'OS'
		when sst.category = 14 then 'PDC'
		when sst.category = 13 then 'CDC'
		end 目的地网点类型
		,case when sst.delivery_frequency = 1 then '一派网点' when sst.delivery_frequency = 2 then '二派网点' end 目的地网点派件频次
		,case
		when sst.category in (8,12) and sst.id in ('TH02030204','TH05110400','TH02030116','TH05110404','TH05110411','TH02030121','TH02030307','TH05110412','TH02030126') then 'BKK'
		when sst.province_code in ('TH01','TH02','TH03','TH04') then 'BKK'
		else 'UPC' end 目的地区域
		,case when sst.category in (8,12) and sst.id in ('TH02030204','TH05110400','TH02030116','TH05110404','TH05110411','TH02030121','TH02030307','TH05110412','TH02030126') then 'B'
		when sst.province_code in ('TH01','TH02','TH03','TH04') then 'B'
		when sst.sorting_no in ('B','C') then 'C'
		else sst.sorting_no end 目的地分拣大区
		,ft1.plan_leave_time
		,ft1.real_leave_time
		,ft2.plan_arrive_time
		,ft2.real_arrive_time
		,timestampdiff(minute,ft1.plan_leave_time,ft2.plan_arrive_time) 计划车程
		,timestampdiff(minute,ft1.real_leave_time,ft2.real_arrive_time) 实际车程
		,sum(fld.running_mileage) over(partition by ft1.proof_id,ft1.store_id order by ft2.plan_arrive_time) 运行里程
		,flrc.parcel_count 包裹数_BI
		,flrc.price 成本
		,flrc.route_out_pic 装载图片地址

		from
		(
			select distinct
			slt.proof_id
			from fle_staging.store_line_task slt
			where 1=1
			and slt.origin_departure_date >= '2023-08-24'
			and slt.origin_departure_date <  '2023-09-06'
		) ft

		join

		(
			select
			ft.store_id
			,ft.store_name
			,ft.next_store_id
			,ft.next_store_name
			,ft.plan_leave_time
			,ft.plan_arrive_time
			,ft.real_leave_time
			,ft.real_arrive_time
			,ft.proof_id
			,ft.line_id
			,ft.line_name
			,ft.line_area
			,ft.line_type
			,ft.line_plate_type
			,ft.line_mode
			from bi_pro.fleet_time ft
			where 1=1
			and ft.leave_type in (2,4)
			and ft.plan_leave_time >= '2023-08-24'
			and ft.plan_leave_time <  date_add('2023-09-06',interval 3 day)
		) ft1
		on ft.proof_id = ft1.proof_id

		left join
		(
			select
			ft.store_id
			,ft.store_name
			,ft.next_store_id
			,ft.next_store_name
			,ft.plan_leave_time
			,ft.plan_arrive_time
			,ft.real_leave_time
			,ft.real_arrive_time
			,ft.proof_id
			,ft.line_id
			,ft.line_name
			,ft.line_area
			,ft.line_type
			,ft.line_plate_type
			,ft.line_mode
			from bi_pro.fleet_time ft
			where 1=1
			and ft.leave_type in (2,4)
			and ft.plan_leave_time >= '2023-08-24'
			and ft.plan_leave_time <  date_add('2023-09-06',interval 3 day)
		) ft2
		on ft1.proof_id = ft2.proof_id
		and ft1.plan_leave_time < ft2.plan_arrive_time

		left join fle_staging.sys_store sso
		on ft1.store_id = sso.id

		left join fle_staging.sys_store sst
		on ft2.next_store_id = sst.id

		left join bi_pro.fleet_loading_rate_and_cost flrc   #车线价格装载率表
		on ft.proof_id = flrc.proof_id
		and sso.id = flrc.shuttle_begin_id
		and sst.id = flrc.shuttle_end_id

		left join
		(
			select
			fld.origin_id
			,fld.target_id
			,fld.running_mileage
			from fle_staging.fleet_line_distance fld
			where 1=1
			and fld.deleted = 0
			and fld.state = 2
		) fld
		on ft2.store_id = fld.origin_id
		and ft2.next_store_id = fld.target_id

		Left join fle_staging.sys_fleet_van_type fvt
		on ft1.line_plate_type = fvt.code
	) tt
where
    1=1
	and tt.始发网点类型 in ('HUB','BHUB')
	and tt.目的地网点类型 in ('SP','BDC')
    and tt.目的地网点派件频次 = '二派网点'
    and hour(tt.plan_arrive_time) >= 13
    and  hour(tt.plan_arrive_time) < 17