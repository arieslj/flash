select
        fn.region_name as 大区
        ,fn.piece_name as 片区
        ,fn.store_name as 网点
        ,count(distinct fn.pno) as 交接量
        ,count(distinct if(fn.type= '已妥投',fn.pno,null)) as  '已妥投量'
       ,count(distinct if(fn.type= '无留仓/疑难件且无派件标记',fn.pno,null)) +count(distinct if(fn.type= '无留仓/疑难件但有派件标记',fn.pno,null))  as '非留仓/疑难件量'

        ,count(distinct if(fn.type= '留仓件',fn.pno,null)) as  '留仓件量'
       ,count(distinct if(fn.type= '疑难件',fn.pno,null)) as  '疑难件量'
        ,count(distinct if(fn.type= '疑难件'and fn.CN_element1='收件人拒收'  ,fn.pno,null)) as  '疑难件_收件人拒收'
        ,count(distinct if(fn.type= '疑难件'and fn.CN_element1='多次尝试派件失败Multipleattemptstodeliverfailed'  ,fn.pno,null)) as  '疑难件_多次尝试派件失败'
        ,count(distinct if(fn.CN_element1='客户不在家/电话无人接听' and fn.type= '留仓件',fn.pno,null)) as '留仓件_客户不在家/电话无人接听'
       ,count(distinct if(fn.CN_element1='客户改约时间' and fn.type= '留仓件',fn.pno,null)) as '留仓件_客户改约时间'
        ,count(distinct if(fn.CN_element1='当日运力不足，无法派送' and fn.type= '留仓件',fn.pno,null)) as '留仓件_当日运力不足无法派送'
       ,count(distinct if(fn.type= '无留仓/疑难件但有派件标记',fn.pno,null)) as  '非留仓/疑难件但有派件标记量'
       ,count(distinct if(fn.type= '无留仓/疑难件且无派件标记',fn.pno,null)) as  '非留仓/疑难件且无派件标记量'
       ,concat(round(count(distinct if(fn.type= '已妥投',fn.pno,null)) /count(distinct fn.pno)*100,2),'%') as 妥投_交接占比
       ,concat(round((count(distinct if(fn.type= '无留仓/疑难件且无派件标记',fn.pno,null)) +count(distinct if(fn.type= '无留仓/疑难件但有派件标记',fn.pno,null))) /count(distinct fn.pno)*100,2),'%') as '非留仓/疑难件量_交接占比'
       ,concat(round(count(distinct if(fn.type= '留仓件',fn.pno,null)) /count(distinct fn.pno)*100,2),'%') as 留仓件_交接占比
       ,concat(round(count(distinct if(fn.type= '疑难件',fn.pno,null)) /count(distinct fn.pno)*100,2),'%') as 疑难件_交接占比

       ,concat(round(count(distinct if(fn.CN_element1='客户不在家/电话无人接听' and fn.type= '留仓件',fn.pno,null)) /count(distinct fn.pno)*100,2),'%') as '留仓/客户不在家/电话无人接听_交接占比'
       ,concat(round(count(distinct if(fn.CN_element1='客户改约时间' and fn.type= '留仓件',fn.pno,null)) /count(distinct fn.pno)*100,2),'%') as '留仓/客户改约时间_交接占比'
       ,concat(round(count(distinct if(fn.CN_element1='当日运力不足，无法派送' and fn.type= '留仓件',fn.pno,null))/count(distinct fn.pno)*100,2),'%') as '留仓/当日运力不足无法派送_交接占比'

       ,concat(round(count(distinct if(fn.type= '疑难件'and fn.CN_element1='收件人拒收'  ,fn.pno,null)) /count(distinct fn.pno)*100,2),'%') as '疑难件/收件人拒收_交接占比'
       ,concat(round(count(distinct if(fn.type= '疑难件'and fn.CN_element1='多次尝试派件失败Multipleattemptstodeliverfailed'  ,fn.pno,null)) /count(distinct fn.pno)*100,2),'%') as '疑难件/多次尝试派件失败_交接占比'

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
                when (pr.routed_date<pr.finished_date or pr.finished_date is null) and ppd.problem_type is null and ppd1.last_marker is not null  then '无留仓/疑难件但有派件标记'
                when (pr.routed_date<pr.finished_date or pr.finished_date is null) and ppd.problem_type is null and ppd1.last_marker is null  then '无留仓/疑难件且无派件标记'
                when (pr.routed_date<pr.finished_date or pr.finished_date is null) and ppd.problem_type='留仓件'  then '留仓件'
                when (pr.routed_date<pr.finished_date or pr.finished_date is null) and ppd.problem_type='疑难件'  then '疑难件' else 'others' end as type
    from
    (
            select
                *
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
               where date(convert_tz(pr.routed_at,'+00:00','+08:00'))='2023-07-08'
               and pr.route_action in('DELIVERY_TICKET_CREATION_SCAN')
               and dp.store_category =1
          )pr
            where pr.rnk=1
    )pr
    left join
    (
           select
                   pdd.pno
                   ,pdd.CN_element
                   ,pdd.problem_type
                   ,pdd.ppd_created_time
                   ,pdd.ppd_created_date
           from
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
          ) pdd
       where  pdd.rk=1
    )ppd on pr.pno=ppd.pno and pr.routed_date=ppd.ppd_created_date
    left join
    (
           select
                   pdd.pno
                   ,pdd.last_marker
                   ,pdd.ppd_created_time
                   ,pdd.ppd_created_date
           from
          (
             select
                     dt.pno
                     ,dt.staff_info_id
                        ,convert_tz(dt.created_at ,'+00:00','+08:00') as ppd_created_time
                    ,date(convert_tz(dt.created_at ,'+00:00','+08:00')) as ppd_created_date
                     ,tdt2.cn_element as last_marker
                     ,convert_tz(dm.created_at,'+00:00','+08:00') last_marker_time
                     ,row_number() over (partition by dt.pno,date(convert_tz(dt.created_at ,'+00:00','+08:00')) order by dt.created_at desc) as rk
             from ph_staging.ticket_delivery dt
             left join ph_staging.ticket_delivery_marker dm on dt.id=dm.delivery_id
             left join dwm.dwd_dim_dict tdt2 on dm.marker_id= tdt2.element and tdt2.db = 'ph_staging' and tdt2.tablename = 'diff_info' and tdt2.fieldname = 'diff_marker_category'
          ) pdd
       where  pdd.rk=1
    )ppd1 on pr.pno=ppd1.pno and pr.routed_date=ppd1.ppd_created_date
)fn
group by  1,2,3
order by 1