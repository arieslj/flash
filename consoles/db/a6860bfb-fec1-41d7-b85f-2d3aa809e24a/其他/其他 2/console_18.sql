select
    fn.region_name as 大区
	,fn.piece_name as 片区
	,fn.store_name as 网点
    ,fn.staff_info_id as 员工ID
	,count(distinct fn.pno) as '今日交接量(最后一次交接人为准)'
    ,count(distinct if(fn.finished_at is not null,fn.pno,null)) as 今日妥投量
	,count(distinct if(fn.handover_type='17点前交接',fn.pno,null)) as 17点前交接量
    ,count(distinct case when fn.handover_type='17点前交接'  and fn.finished_at is not null then fn.pno else null end) as 17点前交接包裹妥投量
 	,count(distinct case when fn.handover_type='17点前交接'  and fn.finished_at is null then fn.pno else null end) as 17点前交接包裹未妥投量
	,count(distinct case when fn.handover_type='17点前交接' and fn.finished_at is null and fn.before_17_calltimes is null then fn.pno else null end) as 17点前交接包裹未妥投且未拨打电话量
	,count(distinct case when fn.handover_type='17点前交接'  and fn.finished_at is null and fn.before_17_calltimes=1 then fn.pno else null end) as 17点前交接包裹未妥投且拨打电话1次量
	,count(distinct case when fn.handover_type='17点前交接'  and fn.finished_at is null and fn.before_17_calltimes=2 then fn.pno else null end) as 17点前交接包裹未妥投且拨打电话2次量
	,count(distinct case when fn.handover_type='17点前交接'  and fn.finished_at is null and fn.before_17_calltimes=3 then fn.pno else null end) as 17点前交接包裹未妥投且拨打电话3次量
	,count(distinct case when fn.handover_type='17点前交接'  and fn.finished_at is null and fn.before_17_calltimes>3 then fn.pno else null end) as 17点前交接包裹未妥投且拨打电话3次以上量
from
(
    select
		pr.pno
		,pr.store_id
		,pr.store_name
		,pr.piece_name
		,pr.region_name
		,pr.routed_date
		,pr.staff_info_id
	    ,pr.handover_type
        ,pr.finished_at
		,pr2.before_17_calltimes
	from
        ( # 所有交接包裹
            select
                *
                ,case
                    when hour(pr.routed_at)<17 then '17点前交接'
                    else '17点后交接'
                end as handover_type
            from
            (
                select
                        pr.pno
                        ,pr.staff_info_id
                        ,pr.store_id
                        ,dp.store_name
                        ,dp.piece_name
                        ,dp.region_name
                        ,convert_tz(pr.routed_at,'+00:00','+08:00') as routed_at
                        ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
                        ,date(convert_tz(pr.routed_at,'+00:00','+08:00'))  as routed_date
                        ,row_number() over(partition by pr.pno,date(convert_tz(pr.routed_at,'+00:00','+08:00')) order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
                 from ph_staging.parcel_route pr
                left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date ='2023-09-10'
                left join ph_staging.parcel_info pi on pr.pno = pi.pno
                 where
                    pr.routed_at > '2023-09-09 16:00:00'
                    and pr.routed_at < '2023-09-10 16:00:00'
                    and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
                    and dp.store_category =1
            )pr
            where
                pr.rnk = 1
        )pr
	left join
        (
            select
                pr.pno
                ,count(pr.call_datetime) as before_17_calltimes
            from
            (
                    select
                        pr.pno
                        ,pr.staff_info_id
                        ,convert_tz(pr.routed_at,'+00:00','+08:00')  as call_datetime
                 from ph_staging.parcel_route pr
                 left join ph_staging.parcel_info pi on pr.pno=pi.pno
                 where pr.routed_at>'2023-09-09 16:00:00'
                        and pr.routed_at<'2023-09-10 09:00:00'
                 and pr.route_action in('PHONE')
            )pr
            group by 1
        )pr2 on pr.pno = pr2.pno
)fn
group by 1,2,3,4