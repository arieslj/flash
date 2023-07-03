select
        fn.routed_date as 日期
       ,fn.store_name
       ,fn.piece_name
      ,fn.region_name
        ,count(distinct fn.pno) as 交接量
        ,count(distinct if(fn.type= '已妥投',fn.pno,null)) as  '已妥投量'
       ,count(distinct if(fn.type= '交接未留仓标记/疑难件标记',fn.pno,null)) as  '交接未留仓标记/疑难件标记量'
        ,count(distinct if(fn.type= '留仓件',fn.pno,null)) as  '留仓件量'
       ,count(distinct if(fn.type= '疑难件',fn.pno,null)) as  '疑难件量'
        ,count(distinct if(fn.CN_element1='客户不在家/电话无人接听' and fn.type= '留仓件',fn.pno,null)) as '留仓件_客户不在家/电话无人接听_交接占比'
       ,count(distinct if(fn.CN_element1='客户改约时间' and fn.type= '留仓件',fn.pno,null)) as '留仓件_客户改约时间_交接占比'
from
(
    select
        pr.pno
        ,pr.store_id
        ,pr.store_name
        ,pr.piece_name
        ,pr.region_name
        ,pr.routed_date
        ,pr.finished_date
       ,ppd.CN_element as CN_element1
        ,ppd.problem_type
        ,case when pr.routed_date=pr.finished_date then '已妥投'
                when (pr.routed_date<pr.finished_date or pr.finished_date is null) and ppd.problem_type is null  then '交接未留仓标记/疑难件标记'
                when (pr.routed_date<pr.finished_date or pr.finished_date is null) and ppd.problem_type='留仓件'  then '留仓件'
                when (pr.routed_date<pr.finished_date or pr.finished_date is null) and ppd.problem_type='疑难件'  then '疑难件' else 'others' end as type
    from
        (
                select
                    pr.pno
                    ,pr.store_id
                     ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,if(pi.state=5,date(convert_tz(pi.finished_at,'+00:00','+08:00')) ,null) as finished_date
                    ,date(convert_tz(pr.routed_at,'+00:00','+08:00'))  as routed_date
                    ,row_number() over(partition by pr.pno,date(convert_tz(pr.routed_at,'+00:00','+08:00')) order by convert_tz(pr.routed_at,'+00:00','+08:00') desc) as rnk
             from ph_staging.parcel_route pr
            left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pr.store_id and dp.stat_date = date(convert_tz(pr.routed_at,'+00:00','+08:00'))
             left join ph_staging.parcel_info pi on pr.pno=pi.pno
             where pr.routed_at>= date_sub(now(),interval 1 month)
             and pr.route_action in('DELIVERY_TICKET_CREATION_SCAN')
        )pr
    join
        (
            select
                dp.stat_date
                ,dp.store_id
                ,dp.store_name
            from dwm.dwm_ph_staff_wide_s dp
            where
                dp.stat_date >= date_sub(curdate(), interval 1 month )
                and dp.handover_par_cnt > 150
            group by 1,2
        ) dm on pr.routed_date = dm.stat_date and dm.store_id = pr.store_id
    left join
        (
           select
               ppd.pno
               ,ddd.CN_element
               ,case when ppd.parcel_problem_type_category = 2 then '留仓件' when ppd.parcel_problem_type_category = 1 then '疑难件' else null end as problem_type
                ,convert_tz(ppd.created_at,'+00:00','+08:00') as ppd_created_time
               ,date(convert_tz(ppd.created_at,'+00:00','+08:00')) as ppd_created_date
              ,row_number() over(partition by ppd.pno,date(convert_tz(ppd.created_at,'+00:00','+08:00')) order by convert_tz(ppd.created_at,'+00:00','+08:00') desc) as rk
           from ph_staging.parcel_problem_detail ppd
           left join dwm.dwd_dim_dict ddd on ddd.element = ppd.diff_marker_category and ddd.tablename = 'diff_info' and ddd.fieldname = 'diff_marker_category' and ddd.db = 'ph_staging'
           where ppd.parcel_problem_type_category  in(1,2)
        ) ppd  on pr.pno=ppd.pno and pr.routed_date=ppd.ppd_created_date and ppd.rk=1
where pr.rnk=1
)fn
group by  1,2,3,4
order by 1