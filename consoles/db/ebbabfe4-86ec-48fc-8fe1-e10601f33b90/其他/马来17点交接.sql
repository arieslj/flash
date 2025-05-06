/*
定义：统计包裹最后交接扫描的员工，电话次数不限制为最后交接员工拨打的次数，统计包裹维度今日呼出次数
*/
select
    fn.region_name as 大区
	,fn.piece_name as 片区
	,fn.store_name as 网点
    ,fn.staff_info_id as 员工ID

	,count(distinct if(fn.handover_type='17点前交接' ,fn.pno, null)) as 17点前交接量
    ,count(distinct if(fn.handover_type='17点前交接' and fn.pi_state = 5,fn.pno,null)) 17点前交接包裹妥投量
    ,count(distinct if(fn.handover_type='17点前交接' and fn.pi_state = 7,fn.pno,null)) 17点前交接包裹退件量
    ,count(distinct if(fn.handover_type='17点前交接' and fn.pi_state = 8,fn.pno,null)) 17点前交接包裹异常关闭量

    ,count(distinct if(fn.handover_type='17点前交接' and fn.pi_state not in (5,7,8,9),fn.pno,null)) 17点前交接包裹未终态量

	,count(distinct case when fn.handover_type='17点前交接' and fn.pi_state not in (5,7,8,9) and fn.before_17_calltimes is null then fn.pno else null end) as 17点前交接包裹未妥投且未拨打电话量
	,count(distinct case when fn.handover_type='17点前交接'  and fn.pi_state not in (5,7,8,9) and fn.before_17_calltimes = 1 then fn.pno else null end) as 17点前交接包裹未妥投且拨打电话1次量
	,count(distinct case when fn.handover_type='17点前交接'  and fn.pi_state not in (5,7,8,9) and fn.before_17_calltimes = 2 then fn.pno else null end) as 17点前交接包裹未妥投且拨打电话2次量
	,count(distinct case when fn.handover_type='17点前交接'  and fn.pi_state not in (5,7,8,9) and fn.before_17_calltimes = 3 then fn.pno else null end) as 17点前交接包裹未妥投且拨打电话3次量
	,count(distinct case when fn.handover_type='17点前交接'  and fn.pi_state not in (5,7,8,9) and fn.before_17_calltimes > 3 then fn.pno else null end) as 17点前交接包裹未妥投且拨打电话3次以上量
from
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.store_name
            ,pr.piece_name
            ,pr.region_name
            ,pr.routed_date
            ,pr.pi_state
            ,pr.staff_info_id
            ,pr.handover_type
            ,pr.finished_at
            ,pr2.before_17_calltimes
        from
            ( # 所有交接包裹
                select
                    pr.*
                    ,if(hour(pr.routed_at) < 17, '17点前交接', '17点后交接') handover_type
                from
                    (
                        select
                            pr.pno
                            ,pr.staff_info_id
                            ,pr.store_id
                            ,dp.store_name
                            ,dp.piece_name
                            ,dp.region_name
                            ,pi.state pi_state
                            ,convert_tz(pr.routed_at,'+00:00','+08:00') as routed_at
                            ,convert_tz(pi.finished_at,'+00:00','+08:00') as finished_at
                            ,date(convert_tz(pr.routed_at,'+00:00','+08:00'))  as routed_date
                            ,row_number() over(partition by pr.pno,date(convert_tz(pr.routed_at,'+00:00','+08:00')) order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
                        from my_staging.parcel_route pr
                        left join dwm.dim_my_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
                        left join my_staging.parcel_info pi on pr.pno = pi.pno
                        where
                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
                            and pr.routed_at < date_add(curdate(), interval 16 hour)
                            and pr.route_action in ('DELIVERY_TICKET_CREATION_SCAN')
                            and dp.store_category = 1 -- 限制SP
                    ) pr
                where
                    pr.rnk=1
            ) pr
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
                         from my_staging.parcel_route pr
#                          left join my_staging.parcel_info pi on pr.pno=pi.pno
                         where
                            pr.routed_at >= date_sub(curdate(), interval 8 hour)
                            and pr.routed_at < date_add(curdate(), interval 9 hour)
                            and pr.route_action in ('PHONE')
                    )pr
                group by 1
            ) pr2 on pr.pno = pr2.pno
    ) fn
group by 1,2,3,4
order by 1,2,3