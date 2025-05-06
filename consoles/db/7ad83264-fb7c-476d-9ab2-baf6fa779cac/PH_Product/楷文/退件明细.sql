
select
    fn.*
from
    (
        select
          date (convert_tz(pi.created_at,'+00:00','+08:00')) 日期
		,pi.ticket_pickup_store_id
	    ,dp.store_name
		,dp.piece_name
		,dp.region_name
		,db.client_name
		,convert_tz(pi.created_at,'+00:00','+08:00') created_at
		,pi.pno returned_pno
        ,pi2.pno
		,ps.third_sorting_code
        ,ppd1.last_marker
        ,ppd1.staff_info_id last_marker_staff_info_id
		,row_number() over(partition by pi2.pno order by convert_tz(ps.created_at,'+00:00','+08:00') desc) as rnk
	from ph_staging.parcel_info pi
	left join dwm.dwd_dim_bigClient db on pi.client_id=db.client_id
	join dwm.dim_ph_sys_store_rd dp on pi.ticket_pickup_store_id=dp.store_id and dp.stat_date=date_sub(current_date,interval 1 day)
	join ph_staging.parcel_info pi2 on pi.pno=pi2.returned_pno
	left join ph_drds.parcel_sorting_code_info ps on pi2.pno=ps.pno and ps.created_at<concat(date_sub(current_date,interval 1 day),' 16:00:00')
	left join
		(
		    select
		            pdd.pno
		            ,pdd.last_marker
		            ,pdd.staff_info_id
		            ,pdd.ppd_created_time
		    from
			(
				select
				        dt.pno
				        ,dt.staff_info_id
		                ,convert_tz(dt.created_at ,'+00:00','+08:00') as ppd_created_time
				        ,tdt2.cn_element as last_marker
				        ,convert_tz(dm.created_at,'+00:00','+08:00') last_marker_time
				        ,row_number() over (partition by dt.pno order by dt.created_at desc) as rk
				from ph_staging.ticket_delivery dt
				left join ph_staging.ticket_delivery_marker dm on dt.id=dm.delivery_id
				left join dwm.dwd_dim_dict tdt2 on dm.marker_id= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category'
				where
				    dt.created_at > '2024-05-01 16:00:00'
				    -- and dt.created_at < '2024-06-09 16:00:00'
			) pdd
			where  pdd.rk=1
		)ppd1 on pi2.pno=ppd1.pno
	where pi.returned=1
	and pi.created_at > '2024-05-05 16:00:00'
	and pi.created_at < '2024-06-09 16:00:00'
    )fn
where fn.rnk=1