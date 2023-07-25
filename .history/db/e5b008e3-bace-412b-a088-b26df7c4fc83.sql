with t as
(
    select
        pr.pno
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
        ,pr.staff_info_id
        ,pr.store_id
        ,hsi.formal
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    from ph_staging.parcel_route pr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
    where
        pr.routed_at >= '2023-07-07 16:00:00'
        and pr.routed_at < '2023-07-08 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
)
,b as
(
    select
        t1.*
        ,a.staff_num
    from t t1
    left join
        (
            select
                t1.pr_date
                ,t1.pno
                ,count(distinct t1.staff_info_id) staff_num
            from t t1
            group by 1,2
        ) a on t1.pr_date = a.pr_date and t1.pno = a.pno
)
select
    a.region_name 大区
    ,a.piece_name 片区
    ,a.store_name 网点
    ,count(a.pno) 网点总计
    ,count(if(a.type = '正式快递员未标记', a.pno, null )) 正式快递员未标记
    ,count(if(a.type = '众包快递员未标记', a.pno, null )) 众包快递员未标记
    ,count(if(a.type = '交接下班员工', a.pno, null )) 交接下班员工
    ,count(if(a.type = '仓管员未标记', a.pno, null )) 仓管员未标记
from
    (
        select
            dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,b1.pno
            ,case
                when b1.staff_num = 1 and td.pno is null and b1.formal = 1 then '正式快递员未标记'
                when b1.staff_num = 1 and td.pno is null and b1.formal != 1 then '众包快递员未标记'
                when b1.staff_num >= 2 and td.pno is null then '交接下班员工'
                else '仓管员未标记'
            end type
        from
            (
                select
                    b1.*
                    ,ppd.created_at
                    ,ppd.parcel_problem_type_category
                from b b1
                left join  ph_staging.parcel_problem_detail ppd on ppd.pno = b1.pno and ppd.created_at >= '2023-07-07 16:00:00' and ppd.created_at < '2023-07-08 16:00:00'
                where
                    ppd.pno is null
            ) b1
        left join
            (
                select
                    td.pno
                from ph_staging.ticket_delivery td
                left join  ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    tdm.created_at >= '2023-07-07 16:00:00'
                    and tdm.created_at < '2023-07-08 16:00:00'
                group by 1
            ) td on td.pno = b1.pno
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
    ) a
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
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
order by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.pno
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
        ,pr.staff_info_id
        ,pr.store_id
        ,hsi.formal
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    from ph_staging.parcel_route pr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
    where
        pr.routed_at >= '2023-07-07 16:00:00'
        and pr.routed_at < '2023-07-08 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
)
,b as
(
    select
        t1.*
        ,a.staff_num
    from t t1
    left join
        (
            select
                t1.pr_date
                ,t1.pno
                ,count(distinct t1.staff_info_id) staff_num
            from t t1
            group by 1,2
        ) a on t1.pr_date = a.pr_date and t1.pno = a.pno
)
select
    a.region_name 大区
    ,a.piece_name 片区
    ,a.store_name 网点
    ,count(a.pno) 网点总计
    ,count(if(a.type = '正式快递员未标记', a.pno, null )) 正式快递员未标记
    ,count(if(a.type = '众包快递员未标记', a.pno, null )) 众包快递员未标记
    ,count(if(a.type = '交接下班员工', a.pno, null )) 交接下班员工
    ,count(if(a.type = '仓管员未标记', a.pno, null )) 仓管员未标记
from
    (
        select
            dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,b1.pno
            ,case
                when b1.staff_num = 1 and td.pno is null and b1.formal = 1 then '正式快递员未标记'
                when b1.staff_num = 1 and td.pno is null and b1.formal != 1 then '众包快递员未标记'
                when b1.staff_num >= 2 and td.pno is null then '交接下班员工'
                else '仓管员未标记'
            end type
        from
            (
                select
                    b1.*
                    ,ppd.created_at
                    ,ppd.parcel_problem_type_category
                from b b1
                left join ph_staging.parcel_info pi on pi.pno = b1.pno
                left join  ph_staging.parcel_problem_detail ppd on ppd.pno = b1.pno and ppd.created_at >= '2023-07-07 16:00:00' and ppd.created_at < '2023-07-08 16:00:00'
                where
                    ppd.pno is null
                    and pi.state != 5
            ) b1
        left join
            (
                select
                    td.pno
                from ph_staging.ticket_delivery td
                left join  ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    tdm.created_at >= '2023-07-07 16:00:00'
                    and tdm.created_at < '2023-07-08 16:00:00'
                group by 1
            ) td on td.pno = b1.pno
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
    ) a
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.pno
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
        ,pr.staff_info_id
        ,pr.store_id
        ,hsi.formal
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    from ph_staging.parcel_route pr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
    where
        pr.routed_at >= '2023-07-07 16:00:00'
        and pr.routed_at < '2023-07-08 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
)
,b as
(
    select
        t1.*
        ,a.staff_num
    from t t1
    left join
        (
            select
                t1.pr_date
                ,t1.pno
                ,count(distinct t1.staff_info_id) staff_num
            from t t1
            group by 1,2
        ) a on t1.pr_date = a.pr_date and t1.pno = a.pno
)
# select
#     a.region_name 大区
#     ,a.piece_name 片区
#     ,a.store_name 网点
#     ,count(a.pno) 网点总计
#     ,count(if(a.type = '正式快递员未标记', a.pno, null )) 正式快递员未标记
#     ,count(if(a.type = '众包快递员未标记', a.pno, null )) 众包快递员未标记
#     ,count(if(a.type = '交接下班员工', a.pno, null )) 交接下班员工
#     ,count(if(a.type = '仓管员未标记', a.pno, null )) 仓管员未标记
# from
#     (
        select
            dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,b1.pno
            ,case
                when b1.staff_num = 1 and td.pno is null and b1.formal = 1 then '正式快递员未标记'
                when b1.staff_num = 1 and td.pno is null and b1.formal != 1 then '众包快递员未标记'
                when b1.staff_num >= 2 and td.pno is null then '交接下班员工'
                else '仓管员未标记'
            end type
        from
            (
                select
                    b1.*
                    ,ppd.created_at
                    ,ppd.parcel_problem_type_category
                from b b1
                left join ph_staging.parcel_info pi on pi.pno = b1.pno
                left join  ph_staging.parcel_problem_detail ppd on ppd.pno = b1.pno and ppd.created_at >= '2023-07-07 16:00:00' and ppd.created_at < '2023-07-08 16:00:00'
                where
                    ppd.pno is null
                    and pi.state != 5
            ) b1
        left join
            (
                select
                    td.pno
                from ph_staging.ticket_delivery td
                left join  ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    tdm.created_at >= '2023-07-07 16:00:00'
                    and tdm.created_at < '2023-07-08 16:00:00'
                group by 1
            ) td on td.pno = b1.pno
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day );
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.pno
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
        ,pr.staff_info_id
        ,pr.store_id
        ,hsi.formal
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    from ph_staging.parcel_route pr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
    where
        pr.routed_at >= '2023-07-07 16:00:00'
        and pr.routed_at < '2023-07-08 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
)
,b as
(
    select
        t1.*
        ,a.staff_num
    from t t1
    left join
        (
            select
                t1.pr_date
                ,t1.pno
                ,count(distinct t1.staff_info_id) staff_num
            from t t1
            group by 1,2
        ) a on t1.pr_date = a.pr_date and t1.pno = a.pno
)
# select
#     a.region_name 大区
#     ,a.piece_name 片区
#     ,a.store_name 网点
#     ,count(a.pno) 网点总计
#     ,count(if(a.type = '正式快递员未标记', a.pno, null )) 正式快递员未标记
#     ,count(if(a.type = '众包快递员未标记', a.pno, null )) 众包快递员未标记
#     ,count(if(a.type = '交接下班员工', a.pno, null )) 交接下班员工
#     ,count(if(a.type = '仓管员未标记', a.pno, null )) 仓管员未标记
# from
#     (
        select
            dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,b1.pno
            ,case
                when b1.staff_num = 1 and td.pno is null and b1.formal = 1 then '正式快递员未标记'
                when b1.staff_num = 1 and td.pno is null and b1.formal != 1 then '众包快递员未标记'
                when b1.staff_num >= 2 and td.pno is null then '交接下班员工'
                else '仓管员未标记'
            end type
        from
            (
                select
                    b1.*
                    ,ppd.created_at
                    ,ppd.parcel_problem_type_category
                from b b1
                left join ph_staging.parcel_info pi on pi.pno = b1.pno
                left join ph_staging.parcel_route pr2 on pr2.pno = b1.pno and pr2.route_action = 'PENDING_RETURN'
                left join ph_staging.parcel_route pr3 on pr3.pno = b1.pno and pr3.route_action = 'DISCARD_RETURN_BKK'
                left join  ph_staging.parcel_problem_detail ppd on ppd.pno = b1.pno and ppd.created_at >= '2023-07-07 16:00:00' and ppd.created_at < '2023-07-08 16:00:00'
                where
                    ppd.pno is null
                    and pi.state != 5
                    and pr2.pno is null
                    and pr3.pno is null
            ) b1
        left join
            (
                select
                    td.pno
                from ph_staging.ticket_delivery td
                left join  ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    tdm.created_at >= '2023-07-07 16:00:00'
                    and tdm.created_at < '2023-07-08 16:00:00'
                group by 1
            ) td on td.pno = b1.pno
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
    ) a
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.pno
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
        ,pr.staff_info_id
        ,pr.store_id
        ,hsi.formal
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    from ph_staging.parcel_route pr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
    where
        pr.routed_at >= '2023-07-07 16:00:00'
        and pr.routed_at < '2023-07-08 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
)
,b as
(
    select
        t1.*
        ,a.staff_num
    from t t1
    left join
        (
            select
                t1.pr_date
                ,t1.pno
                ,count(distinct t1.staff_info_id) staff_num
            from t t1
            group by 1,2
        ) a on t1.pr_date = a.pr_date and t1.pno = a.pno
)
select
    a.region_name 大区
    ,a.piece_name 片区
    ,a.store_name 网点
    ,count(a.pno) 网点总计
    ,count(if(a.type = '正式快递员未标记', a.pno, null )) 正式快递员未标记
    ,count(if(a.type = '众包快递员未标记', a.pno, null )) 众包快递员未标记
    ,count(if(a.type = '交接下班员工', a.pno, null )) 交接下班员工
    ,count(if(a.type = '仓管员未标记', a.pno, null )) 仓管员未标记
from
    (
        select
            dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,b1.pno
            ,case
                when b1.staff_num = 1 and td.pno is null and b1.formal = 1 then '正式快递员未标记'
                when b1.staff_num = 1 and td.pno is null and b1.formal != 1 then '众包快递员未标记'
                when b1.staff_num >= 2 and td.pno is null then '交接下班员工'
                else '仓管员未标记'
            end type
        from
            (
                select
                    b1.*
                    ,ppd.created_at
                    ,ppd.parcel_problem_type_category
                from b b1
                left join ph_staging.parcel_info pi on pi.pno = b1.pno
                left join ph_staging.parcel_route pr2 on pr2.pno = b1.pno and pr2.route_action = 'PENDING_RETURN'
                left join ph_staging.parcel_route pr3 on pr3.pno = b1.pno and pr3.route_action = 'DISCARD_RETURN_BKK'
                left join  ph_staging.parcel_problem_detail ppd on ppd.pno = b1.pno and ppd.created_at >= '2023-07-07 16:00:00' and ppd.created_at < '2023-07-08 16:00:00'
                where
                    ppd.pno is null
                    and pi.state != 5
                    and pr2.pno is null
                    and pr3.pno is null
            ) b1
        left join
            (
                select
                    td.pno
                from ph_staging.ticket_delivery td
                left join  ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    tdm.created_at >= '2023-07-07 16:00:00'
                    and tdm.created_at < '2023-07-08 16:00:00'
                group by 1
            ) td on td.pno = b1.pno
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
    ) a
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.pno
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
        ,pr.staff_info_id
        ,pr.store_id
        ,hsi.formal
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    from ph_staging.parcel_route pr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
    where
        pr.routed_at >= '2023-07-07 16:00:00'
        and pr.routed_at < '2023-07-08 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
)
,b as
(
    select
        t1.*
        ,a.staff_num
    from t t1
    left join
        (
            select
                t1.pr_date
                ,t1.pno
                ,count(distinct t1.staff_info_id) staff_num
            from t t1
            group by 1,2
        ) a on t1.pr_date = a.pr_date and t1.pno = a.pno
)
# select
#     a.region_name 大区
#     ,a.piece_name 片区
#     ,a.store_name 网点
#     ,count(a.pno) 网点总计
#     ,count(if(a.type = '正式快递员未标记', a.pno, null )) 正式快递员未标记
#     ,count(if(a.type = '众包快递员未标记', a.pno, null )) 众包快递员未标记
#     ,count(if(a.type = '交接下班员工', a.pno, null )) 交接下班员工
#     ,count(if(a.type = '仓管员未标记', a.pno, null )) 仓管员未标记
# from
#     (
        select
            dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,b1.pno
            ,case
                when b1.staff_num = 1 and td.pno is null and b1.formal = 1 then '正式快递员未标记'
                when b1.staff_num = 1 and td.pno is null and b1.formal != 1 then '众包快递员未标记'
                when b1.staff_num >= 2 and td.pno is null then '交接下班员工'
                else '仓管员未标记'
            end type
        from
            (
                select
                    b1.*
                    ,ppd.created_at
                    ,ppd.parcel_problem_type_category
                from b b1
                left join ph_staging.parcel_info pi on pi.pno = b1.pno
                left join ph_staging.parcel_route pr2 on pr2.pno = b1.pno and pr2.route_action = 'PENDING_RETURN'
                left join ph_staging.parcel_route pr3 on pr3.pno = b1.pno and pr3.route_action = 'DISCARD_RETURN_BKK'
                left join  ph_staging.parcel_problem_detail ppd on ppd.pno = b1.pno and ppd.created_at >= '2023-07-07 16:00:00' and ppd.created_at < '2023-07-08 16:00:00'
                where
                    ppd.pno is null
                    and pi.state != 5
                    and pr2.pno is null
                    and pr3.pno is null
            ) b1
        left join
            (
                select
                    td.pno
                from ph_staging.ticket_delivery td
                left join  ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    tdm.created_at >= '2023-07-07 16:00:00'
                    and tdm.created_at < '2023-07-08 16:00:00'
                group by 1
            ) td on td.pno = b1.pno
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day );
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.pno
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
        ,pr.staff_info_id
        ,pr.store_id
        ,hsi.formal
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    from ph_staging.parcel_route pr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
    where
        pr.routed_at >= '2023-07-07 16:00:00'
        and pr.routed_at < '2023-07-08 17:00:00' -- 延迟1个小时
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
)
,b as
(
    select
        t1.*
        ,a.staff_num
    from t t1
    left join
        (
            select
                t1.pr_date
                ,t1.pno
                ,count(distinct t1.staff_info_id) staff_num
            from t t1
            group by 1,2
        ) a on t1.pr_date = a.pr_date and t1.pno = a.pno
)
# select
#     a.region_name 大区
#     ,a.piece_name 片区
#     ,a.store_name 网点
#     ,count(a.pno) 网点总计
#     ,count(if(a.type = '正式快递员未标记', a.pno, null )) 正式快递员未标记
#     ,count(if(a.type = '众包快递员未标记', a.pno, null )) 众包快递员未标记
#     ,count(if(a.type = '交接下班员工', a.pno, null )) 交接下班员工
#     ,count(if(a.type = '仓管员未标记', a.pno, null )) 仓管员未标记
# from
#     (
        select
            dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,b1.pno
            ,case
                when b1.staff_num = 1 and td.pno is null and b1.formal = 1 then '正式快递员未标记'
                when b1.staff_num = 1 and td.pno is null and b1.formal != 1 then '众包快递员未标记'
                when b1.staff_num >= 2 and td.pno is null then '交接下班员工'
                else '仓管员未标记'
            end type
        from
            (
                select
                    b1.*
                    ,ppd.created_at
                    ,ppd.parcel_problem_type_category
                from b b1
                left join ph_staging.parcel_info pi on pi.pno = b1.pno
                left join ph_staging.parcel_route pr2 on pr2.pno = b1.pno and pr2.route_action = 'PENDING_RETURN'
                left join ph_staging.parcel_route pr3 on pr3.pno = b1.pno and pr3.route_action = 'DISCARD_RETURN_BKK'
                left join  ph_staging.parcel_problem_detail ppd on ppd.pno = b1.pno and ppd.created_at >= '2023-07-07 16:00:00' and ppd.created_at < '2023-07-08 16:00:00'
                where
                    ppd.pno is null
                    and pi.state != 5
                    and pr2.pno is null
                    and pr3.pno is null
            ) b1
        left join
            (
                select
                    td.pno
                from ph_staging.ticket_delivery td
                left join  ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    tdm.created_at >= '2023-07-07 16:00:00'
                    and tdm.created_at < '2023-07-08 16:00:00'
                group by 1
            ) td on td.pno = b1.pno
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
    ) a
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.pno
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
        ,pr.staff_info_id
        ,pr.store_id
        ,hsi.formal
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    from ph_staging.parcel_route pr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
    where
        pr.routed_at >= '2023-07-07 16:00:00'
        and pr.routed_at < '2023-07-08 17:00:00' -- 延迟1个小时
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
)
,b as
(
    select
        t1.*
        ,a.staff_num
    from t t1
    left join
        (
            select
                t1.pr_date
                ,t1.pno
                ,count(distinct t1.staff_info_id) staff_num
            from t t1
            group by 1,2
        ) a on t1.pr_date = a.pr_date and t1.pno = a.pno
)
# select
#     a.region_name 大区
#     ,a.piece_name 片区
#     ,a.store_name 网点
#     ,count(a.pno) 网点总计
#     ,count(if(a.type = '正式快递员未标记', a.pno, null )) 正式快递员未标记
#     ,count(if(a.type = '众包快递员未标记', a.pno, null )) 众包快递员未标记
#     ,count(if(a.type = '交接下班员工', a.pno, null )) 交接下班员工
#     ,count(if(a.type = '仓管员未标记', a.pno, null )) 仓管员未标记
# from
#     (
        select
            dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,b1.pno
            ,case
                when b1.staff_num = 1 and td.pno is null and b1.formal = 1 then '正式快递员未标记'
                when b1.staff_num = 1 and td.pno is null and b1.formal != 1 then '众包快递员未标记'
                when b1.staff_num >= 2 and td.pno is null then '交接下班员工'
                else '仓管员未标记'
            end type
        from
            (
                select
                    b1.*
                    ,ppd.created_at
                    ,ppd.parcel_problem_type_category
                from b b1
                left join ph_staging.parcel_info pi on pi.pno = b1.pno
                left join ph_staging.parcel_route pr2 on pr2.pno = b1.pno and pr2.route_action = 'PENDING_RETURN'
                left join ph_staging.parcel_route pr3 on pr3.pno = b1.pno and pr3.route_action = 'DISCARD_RETURN_BKK'
                left join  ph_staging.parcel_problem_detail ppd on ppd.pno = b1.pno and ppd.created_at >= '2023-07-07 16:00:00' and ppd.created_at < '2023-07-08 16:00:00'
                where
                    ppd.pno is null
                    and pi.state != 5
                    and pr2.pno is null
                    and pr3.pno is null
            ) b1
        left join
            (
                select
                    td.pno
                from ph_staging.ticket_delivery td
                left join  ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    tdm.created_at >= '2023-07-07 16:00:00'
                    and tdm.created_at < '2023-07-08 16:00:00'
                group by 1
            ) td on td.pno = b1.pno
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day );
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.pno
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
        ,pr.staff_info_id
        ,pr.store_id
        ,hsi.formal
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    from ph_staging.parcel_route pr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
    where
        pr.routed_at >= '2023-07-07 16:00:00'
        and pr.routed_at < '2023-07-08 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
)
,b as
(
    select
        t1.*
        ,a.staff_num
    from t t1
    left join
        (
            select
                t1.pr_date
                ,t1.pno
                ,count(distinct t1.staff_info_id) staff_num
            from t t1
            group by 1,2
        ) a on t1.pr_date = a.pr_date and t1.pno = a.pno
)
select
    a.region_name 大区
    ,a.piece_name 片区
    ,a.store_name 网点
    ,count(a.pno) 网点总计
    ,count(if(a.type = '正式快递员未标记', a.pno, null )) 正式快递员未标记
    ,count(if(a.type = '众包快递员未标记', a.pno, null )) 众包快递员未标记
    ,count(if(a.type = '交接下班员工', a.pno, null )) 交接下班员工
    ,count(if(a.type = '仓管员未标记', a.pno, null )) 仓管员未标记
from
    (
        select
            dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,b1.pno
            ,case
                when b1.staff_num = 1 and td.pno is null and b1.formal = 1 then '正式快递员未标记'
                when b1.staff_num = 1 and td.pno is null and b1.formal != 1 then '众包快递员未标记'
                when b1.staff_num >= 2 and td.pno is null then '交接下班员工'
                else '仓管员未标记'
            end type
        from
            (
                select
                    b1.*
                    ,ppd.created_at
                    ,ppd.parcel_problem_type_category
                from b b1
                left join ph_staging.parcel_info pi on pi.pno = b1.pno
                left join ph_staging.parcel_route pr2 on pr2.pno = b1.pno and pr2.route_action = 'PENDING_RETURN'
                left join ph_staging.parcel_route pr3 on pr3.pno = b1.pno and pr3.route_action = 'DISCARD_RETURN_BKK'
                left join  ph_staging.parcel_problem_detail ppd on ppd.pno = b1.pno and ppd.created_at >= '2023-07-07 16:00:00' and ppd.created_at < '2023-07-08 17:00:00' -- 延迟1个小时
                where
                    ppd.pno is null
                    and pi.state != 5
                    and pr2.pno is null
                    and pr3.pno is null
            ) b1
        left join
            (
                select
                    td.pno
                from ph_staging.ticket_delivery td
                left join  ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    tdm.created_at >= '2023-07-07 16:00:00'
                    and tdm.created_at < '2023-07-08 16:00:00'
                group by 1
            ) td on td.pno = b1.pno
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
    ) a
group by 1,2,3;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.pno
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
        ,pr.staff_info_id
        ,pr.store_id
        ,hsi.formal
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    from ph_staging.parcel_route pr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
    where
        pr.routed_at >= '2023-07-07 16:00:00'
        and pr.routed_at < '2023-07-08 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
)
,b as
(
    select
        t1.*
        ,a.staff_num
    from t t1
    left join
        (
            select
                t1.pr_date
                ,t1.pno
                ,count(distinct t1.staff_info_id) staff_num
            from t t1
            group by 1,2
        ) a on t1.pr_date = a.pr_date and t1.pno = a.pno
)
# select
#     a.region_name 大区
#     ,a.piece_name 片区
#     ,a.store_name 网点
#     ,count(a.pno) 网点总计
#     ,count(if(a.type = '正式快递员未标记', a.pno, null )) 正式快递员未标记
#     ,count(if(a.type = '众包快递员未标记', a.pno, null )) 众包快递员未标记
#     ,count(if(a.type = '交接下班员工', a.pno, null )) 交接下班员工
#     ,count(if(a.type = '仓管员未标记', a.pno, null )) 仓管员未标记
# from
#     (
        select
            dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,b1.pno
            ,case
                when b1.staff_num = 1 and td.pno is null and b1.formal = 1 then '正式快递员未标记'
                when b1.staff_num = 1 and td.pno is null and b1.formal != 1 then '众包快递员未标记'
                when b1.staff_num >= 2 and td.pno is null then '交接下班员工'
                else '仓管员未标记'
            end type
        from
            (
                select
                    b1.*
                    ,ppd.created_at
                    ,ppd.parcel_problem_type_category
                from b b1
                left join ph_staging.parcel_info pi on pi.pno = b1.pno
                left join ph_staging.parcel_route pr2 on pr2.pno = b1.pno and pr2.route_action = 'PENDING_RETURN'
                left join ph_staging.parcel_route pr3 on pr3.pno = b1.pno and pr3.route_action = 'DISCARD_RETURN_BKK'
                left join  ph_staging.parcel_problem_detail ppd on ppd.pno = b1.pno and ppd.created_at >= '2023-07-07 16:00:00' and ppd.created_at < '2023-07-08 17:00:00' -- 延迟1个小时
                where
                    ppd.pno is null
                    and pi.state != 5
                    and pr2.pno is null
                    and pr3.pno is null
            ) b1
        left join
            (
                select
                    td.pno
                from ph_staging.ticket_delivery td
                left join  ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    tdm.created_at >= '2023-07-07 16:00:00'
                    and tdm.created_at < '2023-07-08 16:00:00'
                group by 1
            ) td on td.pno = b1.pno
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day );
;-- -. . -..- - / . -. - .-. -.--
select
    pr.pno
    ,pr.staff_info_id 操作人
    ,hsi.name 操作人姓名
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 换单打印时间
from ph_staging.parcel_route pr
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
where
    pr.route_action = 'REPLACE_PNO'
    and pr.routed_at > '2023-06-30 16:00:00'
    and pr.store_id = 'PH19280F12';
;-- -. . -..- - / . -. - .-. -.--
select
    ra.id
    ,ra.submitter_id 申请人ID
    ,ra.report_id 被举报人
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
    ra.created_at < date_sub(curdate(), interval 8 hour)
    and ra.created_at >= date_sub(curdate(), interval 32 hour)
    and ra.status = 2;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
    ra.created_at < date_sub(curdate(), interval 8 hour)
    and ra.created_at >= date_sub(curdate(), interval 32 hour)
    and ra.status = 2
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,hsi.name 姓名
    ,hsi.hire_date 入职日期
    ,ds.job_title_desc 岗位
    ,a1.event_date 违规日期
    ,hsi.mobile 手机号
    ,ds.store_name 网点
    ,ds.piece_name 片区
    ,ds.region_name 大区
    ,dp.shl_delivery_par_cnt 网点当日应派件量
    ,dp.atd_emp_cnt 网点当日出勤人数_快递员
    ,dp.delivery_par_cnt 网点当日妥投量
    ,ds.handover_par_cnt 员工当日交接量
    ,ds.delivery_par_cnt 员工当日妥投量
    ,ds.pickup_par_cnt 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = hsi.staff_info_id and ds.stat_date = a1.event_date
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = a1.sys_store_id and dp.stat_date = a1.event_date
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 1
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
    ra.created_at < date_sub(curdate(), interval 8 hour)
    and ra.created_at >= date_sub(curdate(), interval 32 hour)
    and ra.status = 2
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,hsi.name 姓名
    ,hsi.hire_date 入职日期
    ,ds.job_title_desc 岗位
    ,a1.event_date 违规日期
    ,a1.举报原因
    ,hsi.mobile 手机号
    ,ds.store_name 网点
    ,ds.piece_name 片区
    ,ds.region_name 大区
    ,dp.shl_delivery_par_cnt 网点当日应派件量
    ,dp.atd_emp_cnt 网点当日出勤人数_快递员
    ,dp.delivery_par_cnt 网点当日妥投量
    ,ds.handover_par_cnt 员工当日交接量
    ,ds.delivery_par_cnt 员工当日妥投量
    ,ds.pickup_par_cnt 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = hsi.staff_info_id and ds.stat_date = a1.event_date
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = a1.sys_store_id and dp.stat_date = a1.event_date
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 1
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
    ra.created_at < date_sub(curdate(), interval 8 hour)
    and ra.created_at >= date_sub(curdate(), interval 32 hour)
    and ra.status = 2
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,hsi.name 姓名
    ,hsi.hire_date 入职日期
    ,ds.job_title_desc 岗位
    ,a1.event_date 违规日期
    ,a1.举报原因
    ,hsi.mobile 手机号
    ,ds.store_name 网点
    ,ds.piece_name 片区
    ,ds.region_name 大区
    ,dp.shl_delivery_par_cnt 网点当日应派件量
    ,dp.atd_emp_cnt 网点当日出勤人数_快递员
    ,dp.delivery_par_cnt 网点当日妥投量
    ,ds.handover_par_cnt 员工当日交接量
    ,ds.delivery_par_cnt 员工当日妥投量
    ,ds.pickup_par_cnt 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = hsi.staff_info_id and ds.stat_date = a1.event_date
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = a1.sys_store_id and dp.stat_date = a1.event_date
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
        ,pi.dst_store_id
        ,pi.client_id
        ,pi.cod_enabled
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-06-14 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,if(t1.returned = 1, '退件', '正向件')  方向
    ,t1.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
#     ,case
#         when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
#         when t1.state = 6 and di.pno is null  then '闪速系统沟通处理中'
#         when t1.state != 6 and plt.pno is not null and plt2.pno is not null then '闪速系统沟通处理中'
#         when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
#         when de.last_store_id = t1.ticket_pickup_store_id and plt2.pno is null then '揽件未发出'
#         when t1.dst_store_id = 'PH19040F05' and plt2.pno is null then '弃件未到拍卖仓'
#         when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
#         else null
#     end 卡点原因
#     ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,pr.store_name 最后有效路由动作网点
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
    ,datediff(now(), de.dst_routed_at) 目的地网点停留时间
    ,de.dst_store 目的地网点
    ,de.src_store 揽收网点
    ,de.pickup_time 揽收时间
    ,de.pick_date 揽收日期
    ,if(hold.pno is not null, 'yes', 'no' ) 是否有holding标记
    ,if(pr3.pno is not null, 'yes', 'no') 是否有待退件标记
    ,td.try_num 尝试派送次数
from t t1
left join ph_staging.ka_profile kp on t1.client_id = kp.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
            and pr.organization_type = 1
        ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
left join
    (
        select
            pr2.pno
        from ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.route_action = 'REFUND_CONFIRM'
        group by 1
    ) hold on hold.pno = t1.pno
left join
    (
        select
            pr2.pno
        from  ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.route_action = 'PENDING_RETURN'
        group by 1
    ) pr3 on pr3.pno = t1.pno
left join
    (
        select
            td.pno
            ,count(distinct date(convert_tz(tdm.created_at, '+00:00', '+08:00'))) try_num
        from ph_staging.ticket_delivery td
        join t t1 on t1.pno = td.pno
        left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
        group by 1
    ) td on td.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
select date_sub(`current_date`, interval 7 day );
;-- -. . -..- - / . -. - .-. -.--
select date_sub(curdate(), interval 7 day );
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
    ra.created_at < date_sub(curdate(), interval 8 hour)
    and ra.created_at >= date_sub(curdate(), interval 32 hour)
    and ra.status = 2
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,hsi.name 姓名
    ,hsi.hire_date 入职日期
    ,ds.job_title_desc 岗位
    ,a1.event_date 违规日期
    ,a1.举报原因
    ,hsi.mobile 手机号

    ,ds.handover_par_cnt 员工当日交接量
    ,ds.delivery_par_cnt 员工当日妥投量
    ,ds.pickup_par_cnt 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,dp.on_emp_cnt 现有快递员数
    ,dp.shl_delivery_par_cnt 网点当日应派件量
    ,dp.delivery_rate 当日妥投率
    ,dp.atd_emp_cnt 网点当日出勤人数_快递员
    ,dp.delivery_par_cnt 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = hsi.staff_info_id and ds.stat_date = a1.event_date
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = a1.sys_store_id and dp.stat_date = a1.event_date
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = dp.store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = dp.store_id
left join
    (
        select
            hsi.sys_store_id
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = dp.store_id;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
    ra.created_at < date_sub(curdate(), interval 8 hour)
    and ra.created_at >= date_sub(curdate(), interval 32 hour)
#     and ra.status = 2
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,hsi.name 姓名
    ,hsi.hire_date 入职日期
    ,ds.job_title_desc 岗位
    ,a1.event_date 违规日期
    ,a1.举报原因
    ,hsi.mobile 手机号

    ,ds.handover_par_cnt 员工当日交接量
    ,ds.delivery_par_cnt 员工当日妥投量
    ,ds.pickup_par_cnt 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,dp.on_emp_cnt 现有快递员数
    ,dp.shl_delivery_par_cnt 网点当日应派件量
    ,dp.delivery_rate 当日妥投率
    ,dp.atd_emp_cnt 网点当日出勤人数_快递员
    ,dp.delivery_par_cnt 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = hsi.staff_info_id and ds.stat_date = a1.event_date
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = a1.sys_store_id and dp.stat_date = a1.event_date
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = dp.store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = dp.store_id
left join
    (
        select
            hsi.sys_store_id
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = dp.store_id;
;-- -. . -..- - / . -. - .-. -.--
select
            hsi.sys_store_id
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1;
;-- -. . -..- - / . -. - .-. -.--
select date_format(date_sub(curdate(), interval 1 month),'%y-%m');
;-- -. . -..- - / . -. - .-. -.--
select date_format(date_sub(curdate(), interval 1 month),'%Y-%m');
;-- -. . -..- - / . -. - .-. -.--
select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
    ra.created_at < date_sub(curdate(), interval 8 hour)
    and ra.created_at >= date_sub(curdate(), interval 32 hour)
    and ra.status = 2
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,hsi.name 姓名
    ,hsi.hire_date 入职日期
    ,ds.job_title_desc 岗位
    ,a1.event_date 违规日期
    ,a1.举报原因
    ,hsi.mobile 手机号

    ,ds.handover_par_cnt 员工当日交接量
    ,ds.delivery_par_cnt 员工当日妥投量
    ,ds.pickup_par_cnt 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,dp.on_emp_cnt 现有快递员数
    ,dp.shl_delivery_par_cnt 网点当日应派件量
    ,dp.delivery_rate 当日妥投率
    ,dp.atd_emp_cnt 网点当日出勤人数_快递员
    ,dp.delivery_par_cnt 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = hsi.staff_info_id and ds.stat_date = a1.event_date
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = a1.sys_store_id and dp.stat_date = a1.event_date
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = dp.store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = dp.store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = dp.store_id;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    date(ra.created_at) = '2023-07-10'
    and ra.status = 2
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,hsi.name 姓名
    ,hsi.hire_date 入职日期
    ,ds.job_title_desc 岗位
    ,a1.event_date 违规日期
    ,a1.举报原因
    ,hsi.mobile 手机号

    ,ds.handover_par_cnt 员工当日交接量
    ,ds.delivery_par_cnt 员工当日妥投量
    ,ds.pickup_par_cnt 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,dp.on_emp_cnt 现有快递员数
    ,dp.shl_delivery_par_cnt 网点当日应派件量
    ,dp.delivery_rate 当日妥投率
    ,dp.atd_emp_cnt 网点当日出勤人数_快递员
    ,dp.delivery_par_cnt 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = hsi.staff_info_id and ds.stat_date = a1.event_date
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = a1.sys_store_id and dp.stat_date = a1.event_date
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = dp.store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = dp.store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = dp.store_id;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    date(ra.created_at) = '2023-07-10'
    and ra.status = 2
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,hsi.name 姓名
    ,hsi.hire_date 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.举报原因
    ,hsi.mobile 手机号
    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区

    ,shl_del.sh_del_num 网点当日应派件量
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量

    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    date(ra.created_at) = '2023-07-10'
    and ra.status = 2
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,a1.id
    ,hsi.name 姓名
    ,hsi.hire_date 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.举报原因
    ,hsi.mobile 手机号
    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区

    ,shl_del.sh_del_num 网点当日应派件量
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量

    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    date(ra.created_at) = '2023-07-10'
    and ra.status = 2
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,a1.id
    ,hsi.name 姓名
    ,hsi.hire_date 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.举报原因
    ,hsi.mobile 手机号
    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区

    ,shl_del.sh_del_num 网点当日应派件量
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量

    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
group by 2;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    date(ra.created_at) = '2023-07-10'
    and ra.status = 2
)

select
    ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,shl_del.delivery_rate 当日妥投率
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
# left join
#     (
#         select
#             pr.staff_info_id
#             ,a1.event_date
#             ,count(distinct pr.pno) num
#         from ph_staging.parcel_route pr
#         join a a1 on a1.report_id = pr.staff_info_id
#         where
#             pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
#             and pr.routed_at < date_add(a1.event_date, interval 16 hour)
#             and pr.route_action = 'RECEIVED'
#         group by 1
#     ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
# left join
#     (
#         select
#             a1.event_date
#             ,hst.staff_info_id
#             ,count(distinct hst.staff_info_id) staf_num
#         from ph_bi.hr_staff_transfer hst
#         left join ph_bi.hr_staff_info  hr on hr.staff_info_id = hst.staff_info_id
#         join a a1 on a1.report_id = hr.staff_info_id and a1.event_date = hst.stat_date
#         where  hst.stat_date =date_sub(current_date,interval 1 day)
#               and hst.state=1
#             and hr.formal=1
#             and hr.is_sub_staff= 0
#             and hst.job_title in (13,110,1000)
#         group by 1,2
#     ) emp_cnt on emp_cnt.staff_info_id = a1.report_id and emp_cnt.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    date(ra.created_at) = '2023-07-10'
    and ra.status = 2
)

select
    ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,shl_del.delivery_rate 当日妥投率
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            a1.event_date
            ,hst.staff_info_id
            ,count(distinct hst.staff_info_id) staf_num
        from ph_bi.hr_staff_transfer hst
        left join ph_bi.hr_staff_info  hr on hr.staff_info_id = hst.staff_info_id
        join a a1 on a1.report_id = hr.staff_info_id and a1.event_date = hst.stat_date
        where  hst.stat_date =date_sub(current_date,interval 1 day)
              and hst.state=1
            and hr.formal=1
            and hr.is_sub_staff= 0
            and hst.job_title in (13,110,1000)
        group by 1,2
    ) emp_cnt on emp_cnt.staff_info_id = a1.report_id and emp_cnt.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    date(ra.created_at) = '2023-07-10'
    and ra.status = 2
)

select
    ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,shl_del.delivery_rate 当日妥投率
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            a1.event_date
            ,hst.store_id
            ,count(distinct hst.staff_info_id) staf_num
        from ph_bi.hr_staff_transfer hst
        left join ph_bi.hr_staff_info  hr on hr.staff_info_id = hst.staff_info_id
        join a a1 on a1.report_id = hr.staff_info_id and a1.event_date = hst.stat_date
        where  hst.stat_date =date_sub(current_date,interval 1 day)
              and hst.state=1
            and hr.formal=1
            and hr.is_sub_staff= 0
            and hst.job_title in (13,110,1000)
        group by 1,2
    ) emp_cnt on emp_cnt.store_id = a1.report_id and emp_cnt.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    date(ra.created_at) = '2023-07-10'
    and ra.status = 2
)

select
    ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,shl_del.delivery_rate 当日妥投率
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            a1.event_date
            ,hst.store_id
            ,count(distinct hst.staff_info_id) staf_num
        from ph_bi.hr_staff_transfer hst
        left join ph_bi.hr_staff_info  hr on hr.staff_info_id = hst.staff_info_id
        join a a1 on a1.report_id = hr.staff_info_id and a1.event_date = hst.stat_date
        where  hst.stat_date =date_sub(current_date,interval 1 day)
              and hst.state=1
            and hr.formal=1
            and hr.is_sub_staff= 0
            and hst.job_title in (13,110,1000)
        group by 1,2
    ) emp_cnt on emp_cnt.store_id = a1.sys_store_id and emp_cnt.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    date(ra.created_at) = '2023-07-10'
    and ra.status = 2
)

select
    ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,shl_del.delivery_rate 当日妥投率
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            a1.event_date
            ,hst.store_id
            ,count(distinct hst.staff_info_id) staf_num
        from ph_bi.hr_staff_transfer hst
        left join ph_bi.hr_staff_info  hr on hr.staff_info_id = hst.staff_info_id
        join a a1 on a1.sys_store_id = hst.store_id and a1.event_date = hst.stat_date
        where  hst.stat_date =date_sub(current_date,interval 1 day)
              and hst.state=1
            and hr.formal=1
            and hr.is_sub_staff= 0
            and hst.job_title in (13,110,1000)
        group by 1,2
    ) emp_cnt on emp_cnt.store_id = a1.sys_store_id and emp_cnt.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    date(ra.created_at) = '2023-07-10'
    and ra.status = 2
)

select
    ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,shl_del.delivery_rate 当日妥投率
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            a1.event_date
            ,hst.store_id
            ,count(distinct hst.staff_info_id) staf_num
        from ph_bi.hr_staff_transfer hst
        left join ph_bi.hr_staff_info  hr on hr.staff_info_id = hst.staff_info_id
        join a a1 on a1.sys_store_id = hst.store_id and a1.event_date = hst.stat_date
        where
            hst.state=1
            and hr.formal=1
            and hr.is_sub_staff= 0
            and hst.job_title in (13,110,1000)
        group by 1,2
    ) emp_cnt on emp_cnt.store_id = a1.sys_store_id and emp_cnt.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    date(ra.created_at) = '2023-07-10'
    and ra.status = 2
)

select
    ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,shl_del.delivery_rate 当日妥投率
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            a1.event_date
            ,hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1,2
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    date(ra.created_at) = '2023-07-10'
    and ra.status = 2
)

select
    ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,shl_del.delivery_rate 当日妥投率
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    date(ra.created_at) = '2023-07-10'
    and ra.status = 2
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,a1.id
    ,hsi.name 姓名
    ,hsi.hire_date 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.举报原因
    ,hsi.mobile 手机号
    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区

    ,shl_del.sh_del_num 网点当日应派件量
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量

    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
group by 2;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    date(ra.created_at) = '2023-07-10'
    and ra.status = 2
)

select
    ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.sh_del_del_num 网点当日应派件妥投量
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,shl_del.delivery_rate 当日妥投率
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    ra.created_at >= curdate()
    and ra.status = 2
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,hsi.name 姓名
    ,hsi.hire_date 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.举报原因
    ,hsi.mobile 手机号

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    ra.created_at >= curdate()
    and ra.status = 2
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,a1.id 举报ID
    ,hsi.name 姓名
    ,hsi.hire_date 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.举报原因
    ,hsi.mobile 手机号

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 2;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    ra.created_at >= curdate()
    and ra.status = 2
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,a1.id 举报ID
    ,hsi.name 姓名
    ,date(hsi.hire_date) 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.举报原因
    ,hsi.mobile 手机号

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 2;
;-- -. . -..- - / . -. - .-. -.--
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';')
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    ra.created_at >= curdate()
    and ra.status = 2
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';')
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id and sa.oss_bucket_type = 'REPORT_AUDIT_IMG'
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    ra.created_at >= curdate()
    and ra.status = 2
group by 1
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,a1.id 举报ID
    ,hsi.name 姓名
    ,date(hsi.hire_date) 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.举报原因
    ,a1.remark 事情描述
    ,hsi.mobile 手机号

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 2;
;-- -. . -..- - / . -. - .-. -.--
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,case ra.reason
        when 1 then '迟到早退'
        when 2 then '连续旷工'
        when 3 then '贪污'
        when 4 then '工作时间或工作地点饮酒'
        when 5 then '持有或吸食毒品'
        when 6 then '违反公司的命令/通知/规则/纪律/规定'
        when 7 then '通过社会媒体污蔑公司'
        when 8 then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 9 then '腐败/滥用职权'
        when 10 then '玩忽职守'
        when 11 then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 12 then '未告知上级或无故旷工'
        when 13 then '上级没有同意请假、没有通过系统请假'
        when 14 then '没有通过系统请假'
        when 15 then '未按时上下班'
        when 16 then '不配合公司的吸毒检查'
        when 17 then '伪造证件'
        when 18 then '粗心大意造成公司重大损失（造成钱丢失）'
        when 19 then '未按照网点规定的时间回款'
        when 20 then '谎报里程'
        when 21 then '煽动/挑衅/损害公司利益'
        when 22 then '失职'
        when 23 then '损害公司名誉'
        when 24 then '不接受或不配合公司的调查'
        when 25 then 'Fake Status'
        when 26 then 'Fake POD'
        when 27 then '工作效率未达到公司的标准(KPI)'
        when 28 then '贪污钱'
        when 29 then '贪污包裹'
        when 30 then '偷盗公司财物'
        when 101 then '一月内虚假妥投大于等于4次'
        when 102 then '包裹被网点KIT扫描后遗失（2件及以上）'
        when 103 then '虚假扫描'
        when 104 then '偷盗包裹'
        when 105 then '仓库内吸烟'
        when 106 then '辱骂客户'
        when 107 then '乱扔包裹'
        when 108 then '一个月内两次及以上虚假取消揽收'
        when 109 then '未经客户同意私自擅闯客户家'
        when 110 then '恶意争抢客户'
    end 举报原因
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';')
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id and sa.oss_bucket_type = 'REPORT_AUDIT_IMG'
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    ra.created_at >= curdate()
    and ra.status = 2
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,tp.cn
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') picture
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join tmpale.tmp_ph_report_reason tp on tp.key = ra.reason
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id and sa.oss_bucket_type = 'REPORT_AUDIT_IMG'
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    ra.created_at >= curdate()
    and ra.status = 2
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,concat(t.cn, t.eng) reason
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') picture
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join tmpale.tmp_ph_report_reason tp on tp.key = ra.reason
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id and sa.oss_bucket_type = 'REPORT_AUDIT_IMG'
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    ra.created_at >= curdate()
    and ra.status = 2
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,concat(tp.cn, tp.eng) reason
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') picture
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join tmpale.tmp_ph_report_reason tp on tp.key = ra.reason
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id and sa.oss_bucket_type = 'REPORT_AUDIT_IMG'
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    ra.created_at >= curdate()
    and ra.status = 2
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,concat(tp.cn, tp.eng) reason
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') picture
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join tmpale.tmp_ph_report_reason tp on tp.key = ra.reason
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id and sa.oss_bucket_type = 'REPORT_AUDIT_IMG'
where
#     ra.created_at < date_sub(curdate(), interval 8 hour)
#     and ra.created_at >= date_sub(curdate(), interval 32 hour)
    ra.created_at >= curdate()
    and ra.status = 2
group by 1
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,a1.id 举报ID
    ,hsi.name 姓名
    ,date(hsi.hire_date) 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.reason 举报原因
    ,a1.remark 事情描述
    ,a1.picture 图片
    ,hsi.mobile 手机号

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 2;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end  运单当前状态
from ph_staging.customer_diff_ticket cdt
left join ph_staging.diff_info di on cdt.diff_info_id = di.id
left join ph_staging.parcel_info pi on pi.pno = di.pno
where
    cdt.state != 1
    and cdt.created_at < '2023-07-10 16:00:00'
    and di.diff_marker_category in (2,17);
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end  运单当前状态
    ,convert_tz(cdt.created_at, '+00:00', '+08:00') 疑难件创建时间
from ph_staging.customer_diff_ticket cdt
left join ph_staging.diff_info di on cdt.diff_info_id = di.id
left join ph_staging.parcel_info pi on pi.pno = di.pno
where
    cdt.state != 1
    and cdt.created_at < '2023-07-10 16:00:00'
    and di.diff_marker_category in (2,17);
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end  运单当前状态
    ,convert_tz(cdt.created_at, '+00:00', '+08:00') 疑难件创建时间
from ph_staging.customer_diff_ticket cdt
left join ph_staging.diff_info di on cdt.diff_info_id = di.id
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    cdt.state != 1
    and cdt.created_at < '2023-07-10 16:00:00'
    and di.diff_marker_category in (2,17);
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end  运单当前状态
    ,bc.client_name
    ,convert_tz(cdt.created_at, '+00:00', '+08:00') 疑难件创建时间
from ph_staging.customer_diff_ticket cdt
left join ph_staging.diff_info di on cdt.diff_info_id = di.id
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    cdt.state != 1
    and cdt.created_at < '2023-07-10 16:00:00'
    and di.diff_marker_category in (2,17);
;-- -. . -..- - / . -. - .-. -.--
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,concat(tp.cn, tp.eng) reason
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') picture
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join tmpale.tmp_ph_report_reason tp on tp.key = ra.reason
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id and sa.oss_bucket_type = 'REPORT_AUDIT_IMG'
where
    ra.created_at >= '2023-07-10'
    and ra.status = 2
    and ra.final_approval_time >= date_sub(curdate(), interval 11 hour)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.pno
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
        ,pr.staff_info_id
        ,pr.store_id
        ,hsi.formal
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    from ph_staging.parcel_route pr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
    where
        pr.routed_at >= '2023-07-09 16:00:00'
        and pr.routed_at < '2023-07-10 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
)
,b as
(
    select
        t1.*
        ,a.staff_num
    from t t1
    left join
        (
            select
                t1.pr_date
                ,t1.pno
                ,count(distinct t1.staff_info_id) staff_num
            from t t1
            group by 1,2
        ) a on t1.pr_date = a.pr_date and t1.pno = a.pno
)
# select
#     a.region_name 大区
#     ,a.piece_name 片区
#     ,a.store_name 网点
#     ,count(a.pno) 网点总计
#     ,count(if(a.type = '正式快递员未标记', a.pno, null )) 正式快递员未标记
#     ,count(if(a.type = '众包快递员未标记', a.pno, null )) 众包快递员未标记
#     ,count(if(a.type = '交接下班员工', a.pno, null )) 交接下班员工
#     ,count(if(a.type = '仓管员未标记', a.pno, null )) 仓管员未标记
# from
#     (
        select
            dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,b1.pno
            ,case
                when b1.staff_num = 1 and td.pno is null and b1.formal = 1 then '正式快递员未标记'
                when b1.staff_num = 1 and td.pno is null and b1.formal != 1 then '众包快递员未标记'
                when b1.staff_num >= 2 and td.pno is null then '交接下班员工'
                else '仓管员未标记'
            end type
        from
            (
                select
                    b1.*
                    ,ppd.created_at
                    ,ppd.parcel_problem_type_category
                from b b1
                left join ph_staging.parcel_info pi on pi.pno = b1.pno
                left join ph_staging.parcel_route pr2 on pr2.pno = b1.pno and pr2.route_action = 'PENDING_RETURN'
                left join ph_staging.parcel_route pr3 on pr3.pno = b1.pno and pr3.route_action = 'DISCARD_RETURN_BKK'
                left join  ph_staging.parcel_problem_detail ppd on ppd.pno = b1.pno and ppd.created_at >= '2023-07-07 16:00:00' and ppd.created_at < '2023-07-08 17:00:00' -- 延迟1个小时
                where
                    ppd.pno is null
                    and pi.state != 5
                    and pr2.pno is null
                    and pr3.pno is null
            ) b1
        left join
            (
                select
                    td.pno
                from ph_staging.ticket_delivery td
                left join  ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    tdm.created_at >= '2023-07-07 16:00:00'
                    and tdm.created_at < '2023-07-08 16:00:00'
                group by 1
            ) td on td.pno = b1.pno
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day );
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.pno
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
        ,pr.staff_info_id
        ,pr.store_id
        ,hsi.formal
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    from ph_staging.parcel_route pr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
    where
        pr.routed_at >= '2023-07-09 16:00:00'
        and pr.routed_at < '2023-07-10 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
)
,b as
(
    select
        t1.*
        ,a.staff_num
    from t t1
    left join
        (
            select
                t1.pr_date
                ,t1.pno
                ,count(distinct t1.staff_info_id) staff_num
            from t t1
            group by 1,2
        ) a on t1.pr_date = a.pr_date and t1.pno = a.pno
)
# select
#     a.region_name 大区
#     ,a.piece_name 片区
#     ,a.store_name 网点
#     ,count(a.pno) 网点总计
#     ,count(if(a.type = '正式快递员未标记', a.pno, null )) 正式快递员未标记
#     ,count(if(a.type = '众包快递员未标记', a.pno, null )) 众包快递员未标记
#     ,count(if(a.type = '交接下班员工', a.pno, null )) 交接下班员工
#     ,count(if(a.type = '仓管员未标记', a.pno, null )) 仓管员未标记
# from
#     (
        select
            dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,b1.pno
            ,b1.staff_info_id
            ,case
                when b1.staff_num = 1 and td.pno is null and b1.formal = 1 then '正式快递员未标记'
                when b1.staff_num = 1 and td.pno is null and b1.formal != 1 then '众包快递员未标记'
                when b1.staff_num >= 2 and td.pno is null then '交接下班员工'
                else '仓管员未标记'
            end type
        from
            (
                select
                    b1.*
                    ,ppd.created_at
                    ,ppd.parcel_problem_type_category
                from b b1
                left join ph_staging.parcel_info pi on pi.pno = b1.pno
                left join ph_staging.parcel_route pr2 on pr2.pno = b1.pno and pr2.route_action = 'PENDING_RETURN'
                left join ph_staging.parcel_route pr3 on pr3.pno = b1.pno and pr3.route_action = 'DISCARD_RETURN_BKK'
                left join  ph_staging.parcel_problem_detail ppd on ppd.pno = b1.pno and ppd.created_at >= '2023-07-07 16:00:00' and ppd.created_at < '2023-07-08 17:00:00' -- 延迟1个小时
                where
                    ppd.pno is null
                    and pi.state != 5
                    and pr2.pno is null
                    and pr3.pno is null
            ) b1
        left join
            (
                select
                    td.pno
                from ph_staging.ticket_delivery td
                left join  ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    tdm.created_at >= '2023-07-09 16:00:00'
                    and tdm.created_at < '2023-07-10 16:00:00'
                group by 1
            ) td on td.pno = b1.pno
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day );
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.pno
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
        ,pr.staff_info_id
        ,pr.store_id
        ,hsi.formal
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    from ph_staging.parcel_route pr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
    where
        pr.routed_at >= '2023-07-09 16:00:00'
        and pr.routed_at < '2023-07-10 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
)
,b as
(
    select
        t1.*
        ,a.staff_num
    from t t1
    left join
        (
            select
                t1.pr_date
                ,t1.pno
                ,count(distinct t1.staff_info_id) staff_num
            from t t1
            group by 1,2
        ) a on t1.pr_date = a.pr_date and t1.pno = a.pno
)
# select
#     a.region_name 大区
#     ,a.piece_name 片区
#     ,a.store_name 网点
#     ,count(a.pno) 网点总计
#     ,count(if(a.type = '正式快递员未标记', a.pno, null )) 正式快递员未标记
#     ,count(if(a.type = '众包快递员未标记', a.pno, null )) 众包快递员未标记
#     ,count(if(a.type = '交接下班员工', a.pno, null )) 交接下班员工
#     ,count(if(a.type = '仓管员未标记', a.pno, null )) 仓管员未标记
# from
#     (
        select
            dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,b1.pno
            ,b1.staff_info_id
            ,case
                when b1.staff_num = 1 and td.pno is null and b1.formal = 1 then '正式快递员未标记'
                when b1.staff_num = 1 and td.pno is null and b1.formal != 1 then '众包快递员未标记'
                when b1.staff_num >= 2 and td.pno is null then '交接下班员工'
                else '仓管员未标记'
            end type
        from
            (
                select
                    b1.*
                    ,ppd.created_at
                    ,ppd.parcel_problem_type_category
                from b b1
                left join ph_staging.parcel_info pi on pi.pno = b1.pno
                left join ph_staging.parcel_route pr2 on pr2.pno = b1.pno and pr2.route_action = 'PENDING_RETURN'
                left join ph_staging.parcel_route pr3 on pr3.pno = b1.pno and pr3.route_action = 'DISCARD_RETURN_BKK'
                left join  ph_staging.parcel_problem_detail ppd on ppd.pno = b1.pno and ppd.created_at >= '2023-07-09 16:00:00' and ppd.created_at < '2023-07-10 16:00:00' -- 延迟1个小时
                where
                    ppd.pno is null
                    and pi.state != 5
                    and pr2.pno is null
                    and pr3.pno is null
            ) b1
        left join
            (
                select
                    td.pno
                from ph_staging.ticket_delivery td
                left join  ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    tdm.created_at >= '2023-07-09 16:00:00'
                    and tdm.created_at < '2023-07-10 16:00:00'
                group by 1
            ) td on td.pno = b1.pno
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day );
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.pno
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
        ,pr.staff_info_id
        ,pr.store_id
        ,hsi.formal
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    from ph_staging.parcel_route pr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
    where
        pr.routed_at >= '2023-07-07 16:00:00'
        and pr.routed_at < '2023-07-08 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
)
,b as
(
    select
        t1.*
        ,a.staff_num
    from t t1
    left join
        (
            select
                t1.pr_date
                ,t1.pno
                ,count(distinct t1.staff_info_id) staff_num
            from t t1
            group by 1,2
        ) a on t1.pr_date = a.pr_date and t1.pno = a.pno
)
# select
#     a.region_name 大区
#     ,a.piece_name 片区
#     ,a.store_name 网点
#     ,count(a.pno) 网点总计
#     ,count(if(a.type = '正式快递员未标记', a.pno, null )) 正式快递员未标记
#     ,count(if(a.type = '众包快递员未标记', a.pno, null )) 众包快递员未标记
#     ,count(if(a.type = '交接下班员工', a.pno, null )) 交接下班员工
#     ,count(if(a.type = '仓管员未标记', a.pno, null )) 仓管员未标记
# from
#     (
        select
            dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,b1.pno
            ,b1.staff_info_id
            ,case
                when b1.staff_num = 1 and td.pno is null and b1.formal = 1 then '正式快递员未标记'
                when b1.staff_num = 1 and td.pno is null and b1.formal != 1 then '众包快递员未标记'
                when b1.staff_num >= 2 and td.pno is null then '交接下班员工'
                else '仓管员未标记'
            end type
        from
            (
                select
                    b1.*
                    ,ppd.created_at
                    ,ppd.parcel_problem_type_category
                from b b1
                left join ph_staging.parcel_info pi on pi.pno = b1.pno
                left join ph_staging.parcel_route pr2 on pr2.pno = b1.pno and pr2.route_action = 'PENDING_RETURN'
                left join ph_staging.parcel_route pr3 on pr3.pno = b1.pno and pr3.route_action = 'DISCARD_RETURN_BKK'
                left join  ph_staging.parcel_problem_detail ppd on ppd.pno = b1.pno and ppd.created_at >= '2023-07-07 16:00:00' and ppd.created_at < '2023-07-08 16:00:00' -- 延迟1个小时
                where
                    ppd.pno is null
                    and pi.state != 5
                    and pr2.pno is null
                    and pr3.pno is null
            ) b1
        left join
            (
                select
                    td.pno
                from ph_staging.ticket_delivery td
                left join  ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    tdm.created_at >= '2023-07-07 16:00:00'
                    and tdm.created_at < '2023-07-08 16:00:00'
                group by 1
            ) td on td.pno = b1.pno
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day );
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.pno
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
        ,pr.staff_info_id
        ,pr.store_id
        ,hsi.formal
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    from ph_staging.parcel_route pr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
    where
        pr.routed_at >= '2023-07-07 16:00:00'
        and pr.routed_at < '2023-07-08 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
)
,b as
(
    select
        t1.*
        ,a.staff_num
    from t t1
    left join
        (
            select
                t1.pr_date
                ,t1.pno
                ,count(distinct t1.staff_info_id) staff_num
            from t t1
            group by 1,2
        ) a on t1.pr_date = a.pr_date and t1.pno = a.pno
)
# select
#     a.region_name 大区
#     ,a.piece_name 片区
#     ,a.store_name 网点
#     ,count(a.pno) 网点总计
#     ,count(if(a.type = '正式快递员未标记', a.pno, null )) 正式快递员未标记
#     ,count(if(a.type = '众包快递员未标记', a.pno, null )) 众包快递员未标记
#     ,count(if(a.type = '交接下班员工', a.pno, null )) 交接下班员工
#     ,count(if(a.type = '仓管员未标记', a.pno, null )) 仓管员未标记
# from
#     (
        select
            dp.region_name
            ,dp.piece_name
            ,dp.store_name
            ,b1.pno
            ,b1.staff_info_id
            ,case
                when b1.staff_num = 1 and td.pno is null and b1.formal = 1 then '正式快递员未标记'
                when b1.staff_num = 1 and td.pno is null and b1.formal != 1 then '众包快递员未标记'
                when b1.staff_num >= 2 and td.pno is null then '交接下班员工'
                else '仓管员未标记'
            end type
        from
            (
                select
                    b1.*
                    ,ppd.created_at
                    ,ppd.parcel_problem_type_category
                from b b1
                left join ph_staging.parcel_info pi on pi.pno = b1.pno
                left join ph_staging.parcel_route pr2 on pr2.pno = b1.pno and pr2.route_action = 'PENDING_RETURN'
                left join ph_staging.parcel_route pr3 on pr3.pno = b1.pno and pr3.route_action = 'DISCARD_RETURN_BKK'
                left join  ph_staging.parcel_problem_detail ppd on ppd.pno = b1.pno and ppd.created_at >= '2023-07-07 16:00:00' and ppd.created_at < '2023-07-08 17:00:00' -- 延迟1个小时
                where
                    ppd.pno is null
                    and pi.state != 5
                    and pr2.pno is null
                    and pr3.pno is null
            ) b1
        left join
            (
                select
                    td.pno
                from ph_staging.ticket_delivery td
                left join  ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
                where
                    tdm.created_at >= '2023-07-07 16:00:00'
                    and tdm.created_at < '2023-07-08 16:00:00'
                group by 1
            ) td on td.pno = b1.pno
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = b1.store_id and dp.stat_date = date_sub(curdate(), interval 1 day );
;-- -. . -..- - / . -. - .-. -.--
select
        pr.pno
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
        ,pr.staff_info_id
        ,pr.store_id
        ,hsi.formal
        ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
    from ph_staging.parcel_route pr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = pr.staff_info_id
    join tmpale.tmp_ph_pno_0710 t on t.pno = pr.pno
    where
        pr.routed_at >= '2023-07-07 16:00:00'
        and pr.routed_at < '2023-07-08 16:00:00'
        and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN';
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,a.attendance_started_at 上班打卡时间
    ,a.attendance_end_at 下班打卡时间
    ,sa.reissue_card_date 补卡时间
from tmpale.tmp_ph_pno_0710 t
left join ph_bi.attendance_data_v2 a on t.staff_info_id = a.staff_info_id and a.stat_date = '2023-07-10'
left join ph_backyard.staff_audit sa on sa.staff_info_id = t.staff_info_id and sa.audit_type = 1 and sa.attendance_type in (2,4) and sa.attendance_date = '2023-07-10';
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,a.attendance_started_at 上班打卡时间
    ,a.attendance_end_at 下班打卡时间
    ,sa.reissue_card_date 补卡时间
from tmpale.tmp_ph_pno_0710 t
left join ph_bi.attendance_data_v2 a on t.staff_info_id = a.staff_info_id and a.stat_date = '2023-07-08'
left join ph_backyard.staff_audit sa on sa.staff_info_id = t.staff_info_id and sa.audit_type = 1 and sa.attendance_type in (2,4) and sa.attendance_date = '2023-07-08';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') gps
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when ldr.pre_login_out_id is not null  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id is not null  and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
    from ph_staging.login_device_record ldr
    where
        ldr.created_at >= date_sub(curdate(), interval 8 hour)
)
select
    t1.*
    ,dev.staff_num 设备登录账号数
from t t1
left join
    (
        select
            t1.device_id
            ,count(distinct t1.staff_info_id) staff_num
        from  t t1
        group by 1
    ) dev on dev.device_id = t1.device_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') gps
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
    from ph_staging.login_device_record ldr
    where
        ldr.created_at >= date_sub(curdate(), interval 8 hour)
)
select
    t1.*
    ,dev.staff_num 设备登录账号数
from t t1
left join
    (
        select
            t1.device_id
            ,count(distinct t1.staff_info_id) staff_num
        from  t t1
        group by 1
    ) dev on dev.device_id = t1.device_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') gps
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    where
        ldr.created_at >= date_sub(curdate(), interval 8 hour)
)
select
    t1.*
    ,dev.staff_num 设备登录账号数
from t t1
left join
    (
        select
            t1.device_id
            ,count(distinct t1.staff_info_id) staff_num
        from  t t1
        group by 1
    ) dev on dev.device_id = t1.device_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    where
        ldr.created_at >= date_sub(curdate(), interval 8 hour)
)
select
    t1.*
    ,dev.staff_num 设备登录账号数
from t t1
left join
    (
        select
            t1.device_id
            ,count(distinct t1.staff_info_id) staff_num
        from  t t1
        group by 1
    ) dev on dev.device_id = t1.device_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    where
        ldr.created_at >= date_sub(curdate(), interval 8 hour)
)
select
    t1.*
    ,dev.staff_num 设备登录账号数
from t t1
left join
    (
        select
            t1.device_id
            ,count(distinct t1.staff_info_id) staff_num
        from  t t1
        group by 1
    ) dev on dev.device_id = t1.device_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
        when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
        when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
        when hsi2.`state` =2 then '离职'
        when hsi2.`state` =3 then '停职'
    end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= date_sub(curdate(), interval 8 hour)
)
select
    t1.*
    ,dev.staff_num 设备登录账号数
from t t1
left join
    (
        select
            t1.device_id
            ,count(distinct t1.staff_info_id) staff_num
        from  t t1
        group by 1
    ) dev on dev.device_id = t1.device_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.device_id order by ldr.created_at) rk
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-10 16:00:00'
        and ldr.created_at < '2023-07-11 16:00:00'
)
select
    t1.*
    ,ds.handover_par_cnt 员工当日交接包裹数
    ,dev.staff_num 设备登录账号数
    ,pr.pno 交接包裹单号
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end 交接包裹当前状态
    ,convert_tz(pr.routed_at, '+00:00', '+08:00') 交接时间
    ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
from t t1
left join t t2 on t2.device_id = t1.device_id and t2.rk = t1.rk + 1
left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-11'
left join
    (
        select
            t1.device_id
            ,count(distinct t1.staff_info_id) staff_num
        from  t t1
        group by 1
    ) dev on dev.device_id = t1.device_id
left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(t2.登录时间, interval 8 hour)
left join ph_staging.parcel_info pi on pr.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.device_id order by ldr.created_at) rk
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-10 16:00:00'
        and ldr.created_at < '2023-07-11 16:00:00'
)
, b as
(
            select
            t1.*
            ,ds.handover_par_cnt 员工当日交接包裹数
            ,dev.staff_num 设备登录账号数
            ,pr.pno 交接包裹单号
            ,case pi.state
                when 1 then '已揽收'
                when 2 then '运输中'
                when 3 then '派送中'
                when 4 then '已滞留'
                when 5 then '已签收'
                when 6 then '疑难件处理中'
                when 7 then '已退件'
                when 8 then '异常关闭'
                when 9 then '已撤销'
            end 交接包裹当前状态
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
            ,row_number() over (partition by pr.pno order by pr.routed_at) rnk
            ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
        from t t1
        left join t t2 on t2.device_id = t1.device_id and t2.rk = t1.rk + 1
        left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-11'
        left join
            (
                select
                    t1.device_id
                    ,count(distinct t1.staff_info_id) staff_num
                from  t t1
                group by 1
            ) dev on dev.device_id = t1.device_id
        left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(t2.登录时间, interval 8 hour)
        left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
select
    *
from b b1
where
    if(b1.sc_time is null , 1 = 1, b1.rnk = 1);
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,ra.report_id
    ,concat(tp.cn, tp.eng) reason
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') picture
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join tmpale.tmp_ph_report_reason tp on tp.key = ra.reason
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id and sa.oss_bucket_type = 'REPORT_AUDIT_IMG'
where
    ra.created_at >= '2023-07-10'
    and ra.status = 2
    and ra.final_approval_time >= date_sub(curdate(), interval 11 hour)
group by 1
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,a1.id 举报ID
    ,hsi.name 姓名
    ,date(hsi.hire_date) 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.reason 举报原因
    ,a1.remark 事情描述
    ,a1.picture 图片
    ,hsi.mobile 手机号

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,case
        when smr.name in ('Area3', 'Area6') then '彭万松'
        when smr.name in ('Area4', 'Area9') then '韩钥'
        when smr.name in ('Area7', 'Area8','Area10', 'Area11','FHome') then '张可新'
        when smr.name in ('Area1', 'Area2','Area5', 'Area12') then '李俊'
    end 负责人
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 2;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from bi_center.fleet_time limit 100;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.device_id order by ldr.created_at) rk
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-10 16:00:00'
        and ldr.created_at < '2023-07-11 16:00:00'
)
, b as
(
            select
            t1.*
            ,ds.handover_par_cnt 员工当日交接包裹数
            ,dev.staff_num 设备登录账号数
            ,pr.pno 交接包裹单号
            ,case pi.state
                when 1 then '已揽收'
                when 2 then '运输中'
                when 3 then '派送中'
                when 4 then '已滞留'
                when 5 then '已签收'
                when 6 then '疑难件处理中'
                when 7 then '已退件'
                when 8 then '异常关闭'
                when 9 then '已撤销'
            end 交接包裹当前状态
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
            ,row_number() over (partition by pr.staff_info_id,pr.pno order by pr.routed_at) rnk
            ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
        from t t1
        left join t t2 on t2.device_id = t1.device_id and t2.rk = t1.rk + 1
        left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-11'
        left join
            (
                select
                    t1.device_id
                    ,count(distinct t1.staff_info_id) staff_num
                from  t t1
                group by 1
            ) dev on dev.device_id = t1.device_id
        left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(t2.登录时间, interval 8 hour)
        left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
select
    *
from b b1
where
    if(b1.sc_time is null , 1 = 1, b1.rnk = 1)
    and b1.归属网点= 'MAL_SP';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.device_id order by ldr.created_at) rk
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-11 16:00:00'
        and ldr.created_at < '2023-07-12 16:00:00'
)
, b as
(
            select
            t1.*
            ,ds.handover_par_cnt 员工当日交接包裹数
            ,dev.staff_num 设备登录账号数
            ,pr.pno 交接包裹单号
            ,case pi.state
                when 1 then '已揽收'
                when 2 then '运输中'
                when 3 then '派送中'
                when 4 then '已滞留'
                when 5 then '已签收'
                when 6 then '疑难件处理中'
                when 7 then '已退件'
                when 8 then '异常关闭'
                when 9 then '已撤销'
            end 交接包裹当前状态
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
            ,row_number() over (partition by pr.staff_info_id,pr.pno order by pr.routed_at) rnk
            ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
        from t t1
        left join t t2 on t2.device_id = t1.device_id and t2.rk = t1.rk + 1
        left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-12'
        left join
            (
                select
                    t1.device_id
                    ,count(distinct t1.staff_info_id) staff_num
                from  t t1
                group by 1
            ) dev on dev.device_id = t1.device_id
        left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(t2.登录时间, interval 8 hour)
        left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
select
    *
from b b1
where
    if(b1.sc_time is null , 1 = 1, b1.rnk = 1);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.device_id order by ldr.created_at) rk
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-11 16:00:00'
        and ldr.created_at < '2023-07-12 16:00:00'
)
, b as
(
            select
            t1.*
            ,ds.handover_par_cnt 员工当日交接包裹数
            ,dev.staff_num 设备登录账号数
            ,pr.pno 交接包裹单号
            ,case pi.state
                when 1 then '已揽收'
                when 2 then '运输中'
                when 3 then '派送中'
                when 4 then '已滞留'
                when 5 then '已签收'
                when 6 then '疑难件处理中'
                when 7 then '已退件'
                when 8 then '异常关闭'
                when 9 then '已撤销'
            end 交接包裹当前状态
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
            ,row_number() over (partition by pr.pno, pr.staff_info_id order by pr.routed_at) rnk
            ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
        from t t1
        left join t t2 on t2.device_id = t1.device_id and t2.rk = t1.rk + 1
        left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-12'
        left join
            (
                select
                    t1.device_id
                    ,count(distinct t1.staff_info_id) staff_num
                from  t t1
                group by 1
            ) dev on dev.device_id = t1.device_id
        left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(t2.登录时间, interval 8 hour)
        left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
select
    *
from b b1
where
    if(b1.sc_time is null , 1 = 1, b1.rnk = 1);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.device_id order by ldr.created_at) rk
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-10 16:00:00'
        and ldr.created_at < '2023-07-11 16:00:00'
)
, b as
(
            select
            t1.*
            ,ds.handover_par_cnt 员工当日交接包裹数
            ,dev.staff_num 设备登录账号数
            ,pr.pno 交接包裹单号
            ,case pi.state
                when 1 then '已揽收'
                when 2 then '运输中'
                when 3 then '派送中'
                when 4 then '已滞留'
                when 5 then '已签收'
                when 6 then '疑难件处理中'
                when 7 then '已退件'
                when 8 then '异常关闭'
                when 9 then '已撤销'
            end 交接包裹当前状态
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
            ,row_number() over (partition by pr.pno, pr.staff_info_id order by pr.routed_at) rnk
            ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
        from t t1
        left join t t2 on t2.device_id = t1.device_id and t2.rk = t1.rk + 1
        left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-11'
        left join
            (
                select
                    t1.device_id
                    ,count(distinct t1.staff_info_id) staff_num
                from  t t1
                group by 1
            ) dev on dev.device_id = t1.device_id
        left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(t2.登录时间, interval 8 hour)
        left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
select
    *
from b b1
where
    if(b1.sc_time is null , 1 = 1, b1.rnk = 1)
    and b1.归属网点= 'MAL_SP';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.device_id order by ldr.created_at) rk
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-10 16:00:00'
        and ldr.created_at < '2023-07-11 16:00:00'
)
, b as
(
            select
            t1.*
            ,ds.handover_par_cnt 员工当日交接包裹数
            ,dev.staff_num 设备登录账号数
            ,pr.pno 交接包裹单号
            ,case pi.state
                when 1 then '已揽收'
                when 2 then '运输中'
                when 3 then '派送中'
                when 4 then '已滞留'
                when 5 then '已签收'
                when 6 then '疑难件处理中'
                when 7 then '已退件'
                when 8 then '异常关闭'
                when 9 then '已撤销'
            end 交接包裹当前状态
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
            ,row_number() over (partition by t1.device_id,pr.pno, pr.staff_info_id order by pr.routed_at) rnk
            ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
        from t t1
        left join t t2 on t2.device_id = t1.device_id and t2.rk = t1.rk + 1
        left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-11'
        left join
            (
                select
                    t1.device_id
                    ,count(distinct t1.staff_info_id) staff_num
                from  t t1
                group by 1
            ) dev on dev.device_id = t1.device_id
        left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(t2.登录时间, interval 8 hour)
        left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
select
    *
from b b1
where
    if(b1.sc_time is null , 1 = 1, b1.rnk = 1)
    and b1.归属网点= 'MAL_SP';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.device_id order by ldr.created_at) rk
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-10 16:00:00'
        and ldr.created_at < '2023-07-11 16:00:00'
)
, b as
(
            select
            t1.*
            ,ds.handover_par_cnt 员工当日交接包裹数
            ,dev.staff_num 设备登录账号数
            ,pr.pno 交接包裹单号
            ,case pi.state
                when 1 then '已揽收'
                when 2 then '运输中'
                when 3 then '派送中'
                when 4 then '已滞留'
                when 5 then '已签收'
                when 6 then '疑难件处理中'
                when 7 then '已退件'
                when 8 then '异常关闭'
                when 9 then '已撤销'
            end 交接包裹当前状态
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
            ,row_number() over (partition by t1.device_id,pr.pno, pr.staff_info_id order by pr.routed_at) rnk
            ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
        from t t1
        left join t t2 on t2.device_id = t1.device_id and t2.rk = t1.rk + 1
        left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-11'
        left join
            (
                select
                    t1.device_id
                    ,count(distinct t1.staff_info_id) staff_num
                from  t t1
                group by 1
            ) dev on dev.device_id = t1.device_id
        left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(t2.登录时间, interval 8 hour)
        left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
select
    *
from b b1
where
    if(b1.sc_time is null , 1 = 1, b1.rnk = 1);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.device_id order by ldr.created_at) rk
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-10 16:00:00'
        and ldr.created_at < '2023-07-11 16:00:00'
)
, b as
(
            select
            t1.*
            ,ds.handover_par_cnt 员工当日交接包裹数
            ,dev.staff_num 设备登录账号数
            ,pr.pno 交接包裹单号
            ,case pi.state
                when 1 then '已揽收'
                when 2 then '运输中'
                when 3 then '派送中'
                when 4 then '已滞留'
                when 5 then '已签收'
                when 6 then '疑难件处理中'
                when 7 then '已退件'
                when 8 then '异常关闭'
                when 9 then '已撤销'
            end 交接包裹当前状态
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
            ,row_number() over (partition by t1.device_id,pr.pno, pr.staff_info_id order by pr.routed_at desc) rnk
            ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
        from t t1
        left join t t2 on t2.device_id = t1.device_id and t2.rk = t1.rk + 1
        left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-11'
        left join
            (
                select
                    t1.device_id
                    ,count(distinct t1.staff_info_id) staff_num
                from  t t1
                group by 1
            ) dev on dev.device_id = t1.device_id
        left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(t2.登录时间, interval 8 hour)
        left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
select
    *
from b b1
where
    if(b1.sc_time is null , 1 = 1, b1.rnk = 1);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.device_id order by ldr.created_at) rk
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-11 16:00:00'
        and ldr.created_at < '2023-07-12 16:00:00'
)
, b as
(
            select
            t1.*
            ,ds.handover_par_cnt 员工当日交接包裹数
            ,dev.staff_num 设备登录账号数
            ,pr.pno 交接包裹单号
            ,case pi.state
                when 1 then '已揽收'
                when 2 then '运输中'
                when 3 then '派送中'
                when 4 then '已滞留'
                when 5 then '已签收'
                when 6 then '疑难件处理中'
                when 7 then '已退件'
                when 8 then '异常关闭'
                when 9 then '已撤销'
            end 交接包裹当前状态
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
            ,row_number() over (partition by t1.device_id,pr.pno, pr.staff_info_id order by pr.routed_at desc) rnk
            ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
        from t t1
        left join t t2 on t2.device_id = t1.device_id and t2.rk = t1.rk + 1
        left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-12'
        left join
            (
                select
                    t1.device_id
                    ,count(distinct t1.staff_info_id) staff_num
                from  t t1
                group by 1
            ) dev on dev.device_id = t1.device_id
        left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(t2.登录时间, interval 8 hour)
        left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
select
    *
from b b1
where
    if(b1.sc_time is null , 1 = 1, b1.rnk = 1);
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.formal

    from ph_bi.hr_staff_info hsi
    left join ph_backyard.staff_todo_list stl on hsi.staff_info_id = stl.staff_info_id
    where
        stl.staff_info_id is null
        and hsi.job_title in (13,110,1000,37);
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.formal

    from ph_bi.hr_staff_info hsi
    left join ph_backyard.staff_todo_list stl on hsi.staff_info_id = stl.staff_info_id
    where
        stl.staff_info_id is null
        and hsi.job_title in (13,110,1000,37) -- 仓管&快递员
        and hsi.state in (1,3);
;-- -. . -..- - / . -. - .-. -.--
select
        hsi.staff_info_id
        ,hsi.formal
        ,hjt.job_name
    from ph_bi.hr_staff_info hsi
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_backyard.staff_todo_list stl on hsi.staff_info_id = stl.staff_info_id
    where
        stl.staff_info_id is null
        and hsi.job_title in (13,110,1000,37) -- 仓管&快递员
        and hsi.state in (1,3);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,hsi.name staff_name
        ,hsi.formal
        ,hjt.job_name
        ,ss.name
        ,smp.name mp_name
        ,smr.name mr_name
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    left join ph_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join ph_staging.sys_manage_region smr on smr.id= ss.manage_region
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_backyard.staff_todo_list stl on hsi.staff_info_id = stl.staff_info_id
    where
        stl.staff_info_id is null
        and hsi.job_title in (13,110,1000,37) -- 仓管&快递员
        and hsi.state in (1,3)
)
select
    t1.staff_info_id 员工ID
    ,t1.staff_name 员工姓名
    ,t1.job_name 职位
    ,t1.name 所属网点
    ,t1.mp_name 所属片区
    ,t1.mr_name 所属大区
    ,swa.end_at 0711下班打卡时间
    ,case sa.equipment_type
        when 1 then 'kit'
        when 3 then 'backyard'
    end 0711下班打卡设备
    ,sa.version 0711下班打卡版本

    ,swa2.end_at 0712下班打卡时间
    ,case sa2.equipment_type
        when 1 then 'kit'
        when 3 then 'backyard'
    end 0712下班打卡设备
    ,sa2.version 0712下班打卡版本
from t t1
left join ph_backyard.staff_work_attendance swa on swa.staff_info_id = t1.staff_info_id and swa.attendance_date = '2023-07-11'
left join ph_staging.staff_account sa on sa.clientid = swa.end_clientid and swa.staff_info_id = sa.staff_info_id

left join ph_backyard.staff_work_attendance swa2 on swa2.staff_info_id = t1.staff_info_id and swa.attendance_date = '2023-07-12'
left join ph_staging.staff_account sa2 on sa2.clientid = swa2.end_clientid and swa2.staff_info_id = sa2.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,hsi.name staff_name
        ,hsi.formal
        ,hjt.job_name
        ,ss.name
        ,smp.name mp_name
        ,smr.name mr_name
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    left join ph_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join ph_staging.sys_manage_region smr on smr.id= ss.manage_region
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_backyard.staff_todo_list stl on hsi.staff_info_id = stl.staff_info_id
    where
        stl.staff_info_id is null
        and hsi.job_title in (13,110,1000,37) -- 仓管&快递员
        and hsi.state in (1,3)
)
select
    t1.staff_info_id 员工ID
    ,t1.staff_name 员工姓名
    ,t1.job_name 职位
    ,t1.name 所属网点
    ,t1.mp_name 所属片区
    ,t1.mr_name 所属大区
    ,swa.end_at 0711下班打卡时间
    ,case sa.equipment_type
        when 1 then 'kit'
        when 3 then 'backyard'
    end 0711下班打卡设备
    ,sa.version 0711下班打卡版本

    ,swa2.end_at 0712下班打卡时间
    ,case sa2.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0712下班打卡设备
    ,sa2.version 0712下班打卡版本
from t t1
left join ph_backyard.staff_work_attendance swa on swa.staff_info_id = t1.staff_info_id and swa.attendance_date = '2023-07-11'
left join ph_staging.staff_account sa on sa.clientid = swa.end_clientid and swa.staff_info_id = sa.staff_info_id

left join ph_backyard.staff_work_attendance swa2 on swa2.staff_info_id = t1.staff_info_id and swa.attendance_date = '2023-07-12'
left join ph_staging.staff_account sa2 on sa2.clientid = swa2.end_clientid and swa2.staff_info_id = sa2.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,hsi.name staff_name
        ,hsi.formal
        ,hjt.job_name
        ,ss.name
        ,smp.name mp_name
        ,smr.name mr_name
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    left join ph_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join ph_staging.sys_manage_region smr on smr.id= ss.manage_region
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_backyard.staff_todo_list stl on hsi.staff_info_id = stl.staff_info_id
    where
        stl.staff_info_id is null
        and hsi.job_title in (13,110,1000,37) -- 仓管&快递员
        and hsi.state in (1,3)
)
select
    t1.staff_info_id 员工ID
    ,t1.staff_name 员工姓名
    ,t1.job_name 职位
    ,t1.name 所属网点
    ,t1.mp_name 所属片区
    ,t1.mr_name 所属大区
    ,swa.end_at 0711下班打卡时间
    ,case sa.equipment_type
        when 1 then 'kit'
        when 3 then 'backyard'
    end 0711下班打卡设备
    ,sa.version 0711下班打卡版本

    ,swa2.end_at 0712下班打卡时间
    ,case sa2.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0712下班打卡设备
    ,sa2.version 0712下班打卡版本
from t t1
left join ph_backyard.staff_work_attendance swa on swa.staff_info_id = t1.staff_info_id and swa.attendance_date = '2023-07-11'
left join ph_staging.staff_account sa on sa.clientid = swa.end_clientid and swa.staff_info_id = sa.staff_info_id

left join ph_backyard.staff_work_attendance swa2 on swa2.staff_info_id = t1.staff_info_id and swa2.attendance_date = '2023-07-12'
left join ph_staging.staff_account sa2 on sa2.clientid = swa2.end_clientid and swa2.staff_info_id = sa2.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,hsi.name staff_name
        ,hsi.formal
        ,hjt.job_name
        ,ss.name
        ,smp.name mp_name
        ,smr.name mr_name
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    left join ph_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join ph_staging.sys_manage_region smr on smr.id= ss.manage_region
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_backyard.staff_todo_list stl on hsi.staff_info_id = stl.staff_info_id
    where
        stl.staff_info_id is null
        and hsi.job_title in (13,110,1000,37) -- 仓管&快递员
        and hsi.state in (1,3)
)
select
    t1.staff_info_id 员工ID
    ,t1.staff_name 员工姓名
    ,t1.job_name 职位
    ,case t1.formal
        when 1 then '正式'
        when 0 then '外协'
        when 2 then '加盟商'
        when 3 then '其他'
    end 员工属性
    ,t1.name 所属网点
    ,t1.mp_name 所属片区
    ,t1.mr_name 所属大区
    ,swa.end_at 0711下班打卡时间
    ,case sa.equipment_type
        when 1 then 'kit'
        when 3 then 'backyard'
    end 0711下班打卡设备
    ,sa.version 0711下班打卡版本

    ,swa2.end_at 0712下班打卡时间
    ,case sa2.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0712下班打卡设备
    ,sa2.version 0712下班打卡版本
from t t1
left join ph_backyard.staff_work_attendance swa on swa.staff_info_id = t1.staff_info_id and swa.attendance_date = '2023-07-11'
left join ph_staging.staff_account sa on sa.clientid = swa.end_clientid and swa.staff_info_id = sa.staff_info_id

left join ph_backyard.staff_work_attendance swa2 on swa2.staff_info_id = t1.staff_info_id and swa2.attendance_date = '2023-07-12'
left join ph_staging.staff_account sa2 on sa2.clientid = swa2.end_clientid and swa2.staff_info_id = sa2.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,hsi.name staff_name
        ,hsi.formal
        ,hjt.job_name
        ,hsi.state
        ,hsi.wait_leave_state
        ,ss.name
        ,smp.name mp_name
        ,smr.name mr_name
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    left join ph_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join ph_staging.sys_manage_region smr on smr.id= ss.manage_region
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_backyard.staff_todo_list stl on hsi.staff_info_id = stl.staff_info_id
    where
        stl.staff_info_id is null
        and hsi.job_title in (13,110,1000,37) -- 仓管&快递员
        and hsi.state in (1,3)
)
select
    t1.staff_info_id 员工ID
    ,t1.staff_name 员工姓名
    ,t1.job_name 职位
    ,case t1.formal
        when 1 then '正式'
        when 0 then '外协'
        when 2 then '加盟商'
        when 3 then '其他'
    end 员工属性
    ,case
        when  t1.`state`=1 and t1.`wait_leave_state` =0 then '在职'
        when  t1.`state`=1 and t1.`wait_leave_state` =1 then '待离职'
        when t1.`state` =2 then '离职'
        when t1.`state` =3 then '停职'
    end 员工状态
    ,t1.name 所属网点
    ,t1.mp_name 所属片区
    ,t1.mr_name 所属大区
    ,swa.end_at 0711下班打卡时间
    ,case sa.equipment_type
        when 1 then 'kit'
        when 3 then 'backyard'
    end 0711下班打卡设备
    ,sa.version 0711下班打卡版本

    ,swa2.end_at 0712下班打卡时间
    ,case sa2.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0712下班打卡设备
    ,sa2.version 0712下班打卡版本
from t t1
left join ph_backyard.staff_work_attendance swa on swa.staff_info_id = t1.staff_info_id and swa.attendance_date = '2023-07-11'
left join ph_staging.staff_account sa on sa.clientid = swa.end_clientid and swa.staff_info_id = sa.staff_info_id

left join ph_backyard.staff_work_attendance swa2 on swa2.staff_info_id = t1.staff_info_id and swa2.attendance_date = '2023-07-12'
left join ph_staging.staff_account sa2 on sa2.clientid = swa2.end_clientid and swa2.staff_info_id = sa2.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,dp.piece_name 片区
        ,dp.region_name 大区
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.device_id order by ldr.created_at) rk
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ss.id and dp.stat_date = date_sub(curdate(), interval 1 day)
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-11 16:00:00'
        and ldr.created_at < '2023-07-12 16:00:00'
)
, b as
(
            select
            t1.*
            ,ds.handover_par_cnt 员工当日交接包裹数
            ,dev.staff_num 设备登录账号数
            ,pr.pno 交接包裹单号
            ,case pi.state
                when 1 then '已揽收'
                when 2 then '运输中'
                when 3 then '派送中'
                when 4 then '已滞留'
                when 5 then '已签收'
                when 6 then '疑难件处理中'
                when 7 then '已退件'
                when 8 then '异常关闭'
                when 9 then '已撤销'
            end 交接包裹当前状态
            ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
            ,row_number() over (partition by t1.device_id,pr.pno, pr.staff_info_id order by pr.routed_at desc) rnk
            ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
        from t t1
        left join t t2 on t2.device_id = t1.device_id and t2.rk = t1.rk + 1
        left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-12'
        left join
            (
                select
                    t1.device_id
                    ,count(distinct t1.staff_info_id) staff_num
                from  t t1
                group by 1
            ) dev on dev.device_id = t1.device_id
        left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(t2.登录时间, interval 8 hour)
        left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
select
    *
from b b1
where
    if(b1.sc_time is null , 1 = 1, b1.rnk = 1);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,hsi.name staff_name
        ,hsi.formal
        ,hjt.job_name
        ,hsi.state
        ,hsi.hire_date
        ,hsi.wait_leave_state
        ,ss.name
        ,smp.name mp_name
        ,smr.name mr_name
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    left join ph_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join ph_staging.sys_manage_region smr on smr.id= ss.manage_region
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_backyard.staff_todo_list stl on hsi.staff_info_id = stl.staff_info_id
    where
        stl.staff_info_id is null
        and hsi.job_title in (13,110,1000,37) -- 仓管&快递员
        and hsi.state in (1,3)
)
select
    t1.staff_info_id 员工ID
    ,t1.staff_name 员工姓名
    ,t1.hire_date 入职时间
    ,t1.job_name 职位
    ,case t1.formal
        when 1 then '正式'
        when 0 then '外协'
        when 2 then '加盟商'
        when 3 then '其他'
    end 员工属性
    ,case
        when  t1.`state`=1 and t1.`wait_leave_state` =0 then '在职'
        when  t1.`state`=1 and t1.`wait_leave_state` =1 then '待离职'
        when t1.`state` =2 then '离职'
        when t1.`state` =3 then '停职'
    end 员工状态
    ,t1.name 所属网点
    ,t1.mp_name 所属片区
    ,t1.mr_name 所属大区
    ,swa.end_at 0711下班打卡时间
    ,case sa.equipment_type
        when 1 then 'kit'
        when 3 then 'backyard'
    end 0711下班打卡设备
    ,sa.version 0711下班打卡版本

    ,swa2.end_at 0712下班打卡时间
    ,case sa2.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0712下班打卡设备
    ,sa2.version 0712下班打卡版本
from t t1
left join ph_backyard.staff_work_attendance swa on swa.staff_info_id = t1.staff_info_id and swa.attendance_date = '2023-07-11'
left join ph_staging.staff_account sa on sa.clientid = swa.end_clientid and swa.staff_info_id = sa.staff_info_id

left join ph_backyard.staff_work_attendance swa2 on swa2.staff_info_id = t1.staff_info_id and swa2.attendance_date = '2023-07-12'
left join ph_staging.staff_account sa2 on sa2.clientid = swa2.end_clientid and swa2.staff_info_id = sa2.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,hsi.name staff_name
        ,hsi.formal
        ,hjt.job_name
        ,hsi.state
        ,hsi.hire_date
        ,hsi.wait_leave_state
        ,ss.name
        ,smp.name mp_name
        ,smr.name mr_name
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    left join ph_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join ph_staging.sys_manage_region smr on smr.id= ss.manage_region
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_backyard.staff_todo_list stl on hsi.staff_info_id = stl.staff_info_id
    where
        stl.staff_info_id is null
        and hsi.job_title in (13,110,1000,37) -- 仓管&快递员
        and hsi.state in (1,3)
)
select
    t1.staff_info_id 员工ID
    ,t1.staff_name 员工姓名
    ,date(t1.hire_date) 入职时间
    ,t1.job_name 职位
    ,case t1.formal
        when 1 then '正式'
        when 0 then '外协'
        when 2 then '加盟商'
        when 3 then '其他'
    end 员工属性
    ,case
        when  t1.`state`=1 and t1.`wait_leave_state` =0 then '在职'
        when  t1.`state`=1 and t1.`wait_leave_state` =1 then '待离职'
        when t1.`state` =2 then '离职'
        when t1.`state` =3 then '停职'
    end 员工状态
    ,t1.name 所属网点
    ,t1.mp_name 所属片区
    ,t1.mr_name 所属大区
    ,swa.end_at 0711下班打卡时间
    ,case sa.equipment_type
        when 1 then 'kit'
        when 3 then 'backyard'
    end 0711下班打卡设备
    ,sa.version 0711下班打卡版本

    ,swa2.end_at 0712下班打卡时间
    ,case sa2.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0712下班打卡设备
    ,sa2.version 0712下班打卡版本
from t t1
left join ph_backyard.staff_work_attendance swa on swa.staff_info_id = t1.staff_info_id and swa.attendance_date = '2023-07-11'
left join ph_staging.staff_account sa on sa.clientid = swa.end_clientid and swa.staff_info_id = sa.staff_info_id

left join ph_backyard.staff_work_attendance swa2 on swa2.staff_info_id = t1.staff_info_id and swa2.attendance_date = '2023-07-12'
left join ph_staging.staff_account sa2 on sa2.clientid = swa2.end_clientid and swa2.staff_info_id = sa2.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
select
    a.client_name
    ,count(a.id) '昨日20-今日20单量'
    ,count(if(a.visit_state in (3,4), a.id, null)) '昨日20-今日20处理完成单量'
    ,count(if(a.beyond_time = 'y', a.id, null)) '昨日20-今日20处理及时完成单量'
from
    (
        select
            vrv.link_id
            ,bc.client_name
            ,vrv.id
            ,vrv.visit_state
            ,vrv.created_at
            ,case
                when vrv.visit_state in (4) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 120 then 'y'
                when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
            end beyond_time
        from nl_production.violation_return_visit vrv
        join dwm.dwd_dim_bigClient bc on vrv.client_id = bc.client_id -- 平台件
        where
            vrv.created_at >= date_sub('2023-07-12', interval 4 hour)
            and vrv.created_at < date_add('2023-07-12', interval 20 hour)
            and vrv.type = 3
    ) a
group by 1
with rollup;
;-- -. . -..- - / . -. - .-. -.--
select
    a.client_name
    ,count(a.id) '昨日20-今日20单量'
    ,count(if(a.visit_state in (3,4), a.id, null)) '昨日20-今日20处理完成单量'
    ,count(if(a.beyond_time = 'y', a.id, null)) '昨日20-今日20处理及时完成单量'
from
    (
        select
            vrv.link_id
            ,bc.client_name
            ,vrv.id
            ,vrv.visit_state
            ,vrv.created_at
            ,case
                when vrv.visit_state in (4) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 120 then 'y'
                when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
            end beyond_time
        from nl_production.violation_return_visit vrv
        join dwm.dwd_dim_bigClient bc on vrv.client_id = bc.client_id -- 平台件
        where
            vrv.created_at >= date_sub('2023-07-13', interval 4 hour)
            and vrv.created_at < date_add('2023-07-13', interval 20 hour)
            and vrv.type = 3
    ) a
group by 1
with rollup;
;-- -. . -..- - / . -. - .-. -.--
select
    coalesce(a2.client_name, '总计') 客户
    ,a2.`昨日20-今日20单量`
    ,a2.`昨日20-今日20处理完成单量`
    ,a2.`昨日20-今日20处理及时完成单量`
from
    (
        select
            a.client_name
            ,count(a.id) '昨日20-今日20单量'
            ,count(if(a.visit_state in (3,4), a.id, null)) '昨日20-今日20处理完成单量'
            ,count(if(a.beyond_time = 'y', a.id, null)) '昨日20-今日20处理及时完成单量'
        from
            (
                select
                    vrv.link_id
                    ,bc.client_name
                    ,vrv.id
                    ,vrv.visit_state
                    ,vrv.created_at
                    ,case
                        when vrv.visit_state in (4) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 120 then 'y'
                        when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
                    end beyond_time
                from nl_production.violation_return_visit vrv
                join dwm.dwd_dim_bigClient bc on vrv.client_id = bc.client_id -- 平台件
                where
                    vrv.created_at >= date_sub('2023-07-13', interval 4 hour)
                    and vrv.created_at < date_add('2023-07-13', interval 20 hour)
                    and vrv.type = 3
            ) a
        group by 1
        with rollup
    ) a2;
;-- -. . -..- - / . -. - .-. -.--
select
    di.pno
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end  运单当前状态
    ,bc.client_name
    ,convert_tz(cdt.created_at, '+00:00', '+08:00') 疑难件创建时间
from ph_staging.customer_diff_ticket cdt
left join ph_staging.diff_info di on cdt.diff_info_id = di.id
left join ph_staging.parcel_info pi on pi.pno = di.pno
join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
where
    cdt.state != 1
    and cdt.created_at < date_sub(curdate(), interval 32 hour)
    and di.diff_marker_category in (2,17);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,hsi.name staff_name
        ,hsi.formal
        ,hjt.job_name
        ,hsi.state
        ,hsi.hire_date
        ,hsi.wait_leave_state
        ,ss.name
        ,smp.name mp_name
        ,smr.name mr_name
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    left join ph_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join ph_staging.sys_manage_region smr on smr.id= ss.manage_region
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_backyard.staff_todo_list stl on hsi.staff_info_id = stl.staff_info_id
    where
        stl.staff_info_id is null
        and hsi.job_title in (13,110,1000,37) -- 仓管&快递员
        and hsi.state in (1,3)
)
select
    t1.staff_info_id 员工ID
    ,t1.staff_name 员工姓名
    ,date(t1.hire_date) 入职时间
    ,t1.job_name 职位
    ,case t1.formal
        when 1 then '正式'
        when 0 then '外协'
        when 2 then '加盟商'
        when 3 then '其他'
    end 员工属性
    ,case
        when  t1.`state`=1 and t1.`wait_leave_state` =0 then '在职'
        when  t1.`state`=1 and t1.`wait_leave_state` =1 then '待离职'
        when t1.`state` =2 then '离职'
        when t1.`state` =3 then '停职'
    end 员工状态
    ,t1.name 所属网点
    ,t1.mp_name 所属片区
    ,t1.mr_name 所属大区

    ,swa.end_at 0711下班打卡时间
    ,swa.end_clientid 0711下班打卡客户端ID
    ,if((ad.`shift_start`<>'' or ad.`shift_end`<>''),1,0) 是否排班
    ,if((ad.`attendance_started_at` is not null or ad.`attendance_end_at` is not null),1,0) 是否出勤
    ,if(ad.leave_type is not null , 1, 0) 是否请假
        ,case sa.equipment_type
            when 1 then 'kit'
            when 3 then 'backyard'
        end 0711下班打卡设备
        ,sa.version 0711下班打卡版本

        ,swa2.end_at 0712下班打卡时间
        ,swa2.end_clientid 0712下班打卡客户端ID
        ,if((ad2.`shift_start`<>'' or ad2.`shift_end`<>''),1,0) 0712是否排班
        ,if((ad2.`attendance_started_at` is not null or ad2.`attendance_end_at` is not null),1,0) 0712是否出勤
        ,if(ad2.leave_type is not null , 1, 0) 0712是否请假
        ,case sa2.equipment_type
            when 1 then 'kit'
            when 2 then 'kit'
            when 3 then 'backyard'
            when 4 then 'fleet'
            when 5 then 'ms'
            when 6 then 'fbi'
            when 7 then 'fh'
            when 8 then 'fls'
            when 9 then 'ces'
        end 0712下班打卡设备
        ,sa2.version 0712下班打卡版本

        ,swa3.end_at 0713下班打卡时间
        ,swa3.end_clientid 0713下班打卡客户端ID
        ,if((ad3.`shift_start`<>'' or ad3.`shift_end`<>''),1,0) 0713是否排班
        ,if((ad3.`attendance_started_at` is not null or ad3.`attendance_end_at` is not null),1,0) 0713是否出勤
        ,if(ad3.leave_type is not null , 1, 0) 0713是否请假
        ,case sa3.equipment_type
            when 1 then 'kit'
            when 2 then 'kit'
            when 3 then 'backyard'
            when 4 then 'fleet'
            when 5 then 'ms'
            when 6 then 'fbi'
            when 7 then 'fh'
            when 8 then 'fls'
            when 9 then 'ces'
        end 0713下班打卡设备
    ,sa3.version 0713下班打卡版本
from t t1
left join ph_backyard.staff_work_attendance swa on swa.staff_info_id = t1.staff_info_id and swa.attendance_date = '2023-07-11'
left join ph_staging.staff_account sa on sa.clientid = swa.end_clientid and swa.staff_info_id = sa.staff_info_id
left join ph_bi.attendance_data_v2 ad on ad.staff_info_id = t1.staff_info_id and ad.stat_date = swa.attendance_date

left join ph_backyard.staff_work_attendance swa2 on swa2.staff_info_id = t1.staff_info_id and swa2.attendance_date = '2023-07-12'
left join ph_staging.staff_account sa2 on sa2.clientid = swa2.end_clientid and swa2.staff_info_id = sa2.staff_info_id
left join ph_bi.attendance_data_v2 ad2 on ad2.staff_info_id = t1.staff_info_id and ad2.stat_date = swa2.attendance_date

left join ph_backyard.staff_work_attendance swa3 on swa3.staff_info_id = t1.staff_info_id and swa3.attendance_date = '2023-07-12'
left join ph_staging.staff_account sa3 on sa3.clientid = swa3.end_clientid and swa3.staff_info_id = sa3.staff_info_id
left join ph_bi.attendance_data_v2 ad3 on ad3.staff_info_id = t1.staff_info_id and ad3.stat_date = swa3.attendance_date;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,hsi.name staff_name
        ,hsi.formal
        ,hjt.job_name
        ,hsi.state
        ,hsi.hire_date
        ,hsi.wait_leave_state
        ,ss.name
        ,smp.name mp_name
        ,smr.name mr_name
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    left join ph_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join ph_staging.sys_manage_region smr on smr.id= ss.manage_region
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_backyard.staff_todo_list stl on hsi.staff_info_id = stl.staff_info_id
    where
        stl.staff_info_id is null
        and hsi.job_title in (13,110,1000,37) -- 仓管&快递员
        and hsi.state in (1,3)
)
select
    t1.staff_info_id 员工ID
    ,t1.staff_name 员工姓名
    ,date(t1.hire_date) 入职时间
    ,t1.job_name 职位
    ,case t1.formal
        when 1 then '正式'
        when 0 then '外协'
        when 2 then '加盟商'
        when 3 then '其他'
    end 员工属性
    ,case
        when  t1.`state`=1 and t1.`wait_leave_state` =0 then '在职'
        when  t1.`state`=1 and t1.`wait_leave_state` =1 then '待离职'
        when t1.`state` =2 then '离职'
        when t1.`state` =3 then '停职'
    end 员工状态
    ,t1.name 所属网点
    ,t1.mp_name 所属片区
    ,t1.mr_name 所属大区

    ,swa.end_at 0711下班打卡时间
    ,swa.end_clientid 0711下班打卡客户端ID
    ,if((ad.`shift_start`<>'' or ad.`shift_end`<>''),1,0) 是否排班
    ,if((ad.`attendance_started_at` is not null or ad.`attendance_end_at` is not null),1,0) 是否出勤
    ,if(ad.leave_type is not null , 1, 0) 是否请假
    ,case sa.equipment_type
        when 1 then 'kit'
        when 3 then 'backyard'
    end 0711下班打卡设备
    ,sa.version 0711下班打卡版本

    ,swa2.end_at 0712下班打卡时间
    ,swa2.end_clientid 0712下班打卡客户端ID
    ,if((ad2.`shift_start`<>'' or ad2.`shift_end`<>''),1,0) 0712是否排班
    ,if((ad2.`attendance_started_at` is not null or ad2.`attendance_end_at` is not null),1,0) 0712是否出勤
    ,if(ad2.leave_type is not null , 1, 0) 0712是否请假
    ,case sa2.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0712下班打卡设备
    ,sa2.version 0712下班打卡版本

    ,swa3.end_at 0713下班打卡时间
    ,swa3.end_clientid 0713下班打卡客户端ID
    ,if((ad3.`shift_start`<>'' or ad3.`shift_end`<>''),1,0) 0713是否排班
    ,if((ad3.`attendance_started_at` is not null or ad3.`attendance_end_at` is not null),1,0) 0713是否出勤
    ,if(ad3.leave_type is not null , 1, 0) 0713是否请假
    ,case sa3.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0713下班打卡设备
    ,sa3.version 0713下班打卡版本
from t t1
left join ph_backyard.staff_work_attendance swa on swa.staff_info_id = t1.staff_info_id and swa.attendance_date = '2023-07-11'
left join ph_staging.staff_account sa on sa.clientid = swa.end_clientid and swa.staff_info_id = sa.staff_info_id
left join ph_bi.attendance_data_v2 ad on ad.staff_info_id = t1.staff_info_id and ad.stat_date = swa.attendance_date

left join ph_backyard.staff_work_attendance swa2 on swa2.staff_info_id = t1.staff_info_id and swa2.attendance_date = '2023-07-12'
left join ph_staging.staff_account sa2 on sa2.clientid = swa2.end_clientid and swa2.staff_info_id = sa2.staff_info_id
left join ph_bi.attendance_data_v2 ad2 on ad2.staff_info_id = t1.staff_info_id and ad2.stat_date = swa2.attendance_date

left join ph_backyard.staff_work_attendance swa3 on swa3.staff_info_id = t1.staff_info_id and swa3.attendance_date = '2023-07-13'
left join ph_staging.staff_account sa3 on sa3.clientid = swa3.end_clientid and swa3.staff_info_id = sa3.staff_info_id
left join ph_bi.attendance_data_v2 ad3 on ad3.staff_info_id = t1.staff_info_id and ad3.stat_date = swa3.attendance_date;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,hsi.name staff_name
        ,hsi.formal
        ,hjt.job_name
        ,hsi.state
        ,hsi.hire_date
        ,hsi.wait_leave_state
        ,ss.name
        ,smp.name mp_name
        ,smr.name mr_name
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    left join ph_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join ph_staging.sys_manage_region smr on smr.id= ss.manage_region
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_backyard.staff_todo_list stl on hsi.staff_info_id = stl.staff_info_id
    where
        stl.staff_info_id is null
        and hsi.job_title in (13,110,1000,37) -- 仓管&快递员
        and hsi.state in (1,3)
)
select
    t1.staff_info_id 员工ID
    ,t1.staff_name 员工姓名
    ,date(t1.hire_date) 入职时间
    ,t1.job_name 职位
    ,case t1.formal
        when 1 then '正式'
        when 0 then '外协'
        when 2 then '加盟商'
        when 3 then '其他'
    end 员工属性
    ,case
        when  t1.`state`=1 and t1.`wait_leave_state` =0 then '在职'
        when  t1.`state`=1 and t1.`wait_leave_state` =1 then '待离职'
        when t1.`state` =2 then '离职'
        when t1.`state` =3 then '停职'
    end 员工状态
    ,t1.name 所属网点
    ,t1.mp_name 所属片区
    ,t1.mr_name 所属大区

    ,swa.end_at 0711下班打卡时间
    ,swa.end_clientid 0711下班打卡客户端ID
    ,if((ad.`shift_start`<>'' or ad.`shift_end`<>''),1,0) 0711是否排班
    ,if((ad.`attendance_started_at` is not null or ad.`attendance_end_at` is not null),1,0) 0711是否出勤
    ,if(length(ad.leave_type ) > 0 , 1, 0) 0711是否请假
    ,case sa.equipment_type
        when 1 then 'kit'
        when 3 then 'backyard'
    end 0711下班打卡设备
    ,sa.version 0711下班打卡版本

    ,swa2.end_at 0712下班打卡时间
    ,swa2.end_clientid 0712下班打卡客户端ID
    ,if((ad2.`shift_start`<>'' or ad2.`shift_end`<>''),1,0) 0712是否排班
    ,if((ad2.`attendance_started_at` is not null or ad2.`attendance_end_at` is not null),1,0) 0712是否出勤
    ,if(length(ad2.leave_type ) > 0 , 1, 0)0712是否请假
    ,case sa2.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0712下班打卡设备
    ,sa2.version 0712下班打卡版本

    ,swa3.end_at 0713下班打卡时间
    ,swa3.end_clientid 0713下班打卡客户端ID
    ,if((ad3.`shift_start`<>'' or ad3.`shift_end`<>''),1,0) 0713是否排班
    ,if((ad3.`attendance_started_at` is not null or ad3.`attendance_end_at` is not null),1,0) 0713是否出勤
    ,if(length(ad3.leave_type ) > 0 , 1, 0) 0713是否请假
    ,case sa3.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0713下班打卡设备
    ,sa3.version 0713下班打卡版本
from t t1
left join ph_backyard.staff_work_attendance swa on swa.staff_info_id = t1.staff_info_id and swa.attendance_date = '2023-07-11'
left join ph_staging.staff_account sa on sa.clientid = swa.end_clientid and swa.staff_info_id = sa.staff_info_id
left join ph_bi.attendance_data_v2 ad on ad.staff_info_id = t1.staff_info_id and ad.stat_date = swa.attendance_date

left join ph_backyard.staff_work_attendance swa2 on swa2.staff_info_id = t1.staff_info_id and swa2.attendance_date = '2023-07-12'
left join ph_staging.staff_account sa2 on sa2.clientid = swa2.end_clientid and swa2.staff_info_id = sa2.staff_info_id
left join ph_bi.attendance_data_v2 ad2 on ad2.staff_info_id = t1.staff_info_id and ad2.stat_date = swa2.attendance_date

left join ph_backyard.staff_work_attendance swa3 on swa3.staff_info_id = t1.staff_info_id and swa3.attendance_date = '2023-07-13'
left join ph_staging.staff_account sa3 on sa3.clientid = swa3.end_clientid and swa3.staff_info_id = sa3.staff_info_id
left join ph_bi.attendance_data_v2 ad3 on ad3.staff_info_id = t1.staff_info_id and ad3.stat_date = swa3.attendance_date;
;-- -. . -..- - / . -. - .-. -.--
select
    hsi.staff_info_id
    ,hsi.name
    ,hsi.hire_date
    ,hsi.hire_times
    ,hsi.hire_date_origin
    ,dp.store_name
    ,dp.piece_name
    ,dp.region_name
from ph_bi.hr_staff_info hsi
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    hsi.formal = 0
    and hsi.state != 2;
;-- -. . -..- - / . -. - .-. -.--
select
    hsi.staff_info_id
    ,hsi.name
    ,hsi.hire_date
    ,hsi.hire_times
    ,hsi.hire_date_origin
    ,dp.store_name
    ,dp.piece_name
    ,dp.region_name
from ph_bi.hr_staff_info hsi
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    hsi.formal = 0
    and hsi.state != 2
    and hsi.hire_date < '2023-07-13';
;-- -. . -..- - / . -. - .-. -.--
select
    hsi.staff_info_id
    ,hsi.name 姓名
    ,case
        when  hsi.`state`=1 and hsi.`wait_leave_state` =0 then '在职'
        when  hsi.`state`=1 and hsi.`wait_leave_state` =1 then '待离职'
        when hsi.`state` =2 then '离职'
        when hsi.`state` =3 then '停职'
    end 员工状态
    ,date(hsi.hire_date)  入职时间
    ,hsi.company_name_ef 外协合作商名
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
from ph_bi.hr_staff_info hsi
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    hsi.formal = 0
    and hsi.state != 2
    and hsi.hire_date < '2023-07-13';
;-- -. . -..- - / . -. - .-. -.--
select
    hsi.staff_info_id
    ,hsi.name 姓名
#     ,case
#         when  hsi.`state`=1 and hsi.`wait_leave_state` =0 then '在职'
#         when  hsi.`state`=1 and hsi.`wait_leave_state` =1 then '待离职'
#         when hsi.`state` =2 then '离职'
#         when hsi.`state` =3 then '停职'
#     end 员工状态
    ,date(hsi.hire_date)  入职时间
    ,hsi.company_name_ef 外协合作商名
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
from ph_bi.hr_staff_info hsi
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    hsi.formal = 0
    and hsi.state != 2
    and hsi.hire_date < '2023-07-13';
;-- -. . -..- - / . -. - .-. -.--
select
                    vrv.link_id
                    ,bc.client_name
                    ,vrv.id
                    ,vrv.visit_state
                    ,vrv.created_at
                    ,case
                        when vrv.visit_state in (4) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 120 then 'y'
                        when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
                    end beyond_time
                from nl_production.violation_return_visit vrv
                join dwm.dwd_dim_bigClient bc on vrv.client_id = bc.client_id
                where
                    vrv.created_at >= date_sub('2023-07-13', interval 4 hour)
                    and vrv.created_at < date_add('2023-07-13', interval 20 hour)
                    and vrv.type = 3;
;-- -. . -..- - / . -. - .-. -.--
select
                    vrv.link_id
                    ,bc.client_name
                    ,vrv.id
                    ,vrv.visit_state
                    ,vrv.created_at
                    ,case
                        when vrv.visit_state in (4) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 120 then 'y'
                        when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
                        when vrv.visit_state in (4) and timestampdiff(minute , vrv.created_at, vrv.updated_at) > 120 then 'n'
                        when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) > 240 then 'n'
                    end beyond_time
                from nl_production.violation_return_visit vrv
                join dwm.dwd_dim_bigClient bc on vrv.client_id = bc.client_id
                where
                    vrv.created_at >= date_sub('2023-07-13', interval 4 hour)
                    and vrv.created_at < date_add('2023-07-13', interval 20 hour)
                    and vrv.type = 3;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,dp.piece_name 片区
        ,dp.region_name 大区
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.device_id order by ldr.created_at) rk
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ss.id and dp.stat_date = date_sub(curdate(), interval 1 day)
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-11 16:00:00'
        and ldr.created_at < '2023-07-12 16:00:00'
)
, b as
(
    select
        t1.*
        ,ds.handover_par_cnt 员工当日交接包裹数
        ,dev.staff_num 设备登录账号数
        ,pr.pno 交接包裹单号
        ,case pi.state
            when 1 then '已揽收'
            when 2 then '运输中'
            when 3 then '派送中'
            when 4 then '已滞留'
            when 5 then '已签收'
            when 6 then '疑难件处理中'
            when 7 then '已退件'
            when 8 then '异常关闭'
            when 9 then '已撤销'
        end 交接包裹当前状态
        ,pr.routed_at
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
        ,row_number() over (partition by t1.device_id,pr.pno, pr.staff_info_id order by pr.routed_at desc) rnk
        ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
    from t t1
    left join t t2 on t2.device_id = t1.device_id and t2.rk = t1.rk + 1
    left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-12'
    left join
        (
            select
                t1.device_id
                ,count(distinct t1.staff_info_id) staff_num
            from  t t1
            group by 1
        ) dev on dev.device_id = t1.device_id
    left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(t2.登录时间, interval 8 hour)
    left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
, pr as
(
    select
        pr2.pno
        ,pr2.staff_info_id
        ,pr2.routed_at
        ,row_number() over (partition by pr2.pno order by pr2.routed_at ) rk
    from ph_staging.parcel_route pr2
    where
        pr2.routed_at >= '2023-07-11 16:00:00'
        and pr2.routed_at < '2023-07-12 16:00:00'
    )
select
    b1.*
    ,if(pr2.staff_info_id is not null, if(pr2.staff_info_id = b1.staff_info_id , '是', '否'), '' ) 包裹上一交接人是否是此人
from
    (
        select
            *
        from b b1
        where
            if(b1.sc_time is null , 1 = 1, b1.rnk = 1)
    ) b1
left join pr pr1 on pr1.pno = b1.交接包裹单号 and pr1.routed_at = b1.routed_at
left join pr pr2 on pr2.pno = pr1.pno and pr2.rk = pr1.rk - 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,dp.piece_name 片区
        ,dp.region_name 大区
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.device_id order by ldr.created_at) rk
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ss.id and dp.stat_date = date_sub(curdate(), interval 1 day)
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-11 16:00:00'
        and ldr.created_at < '2023-07-12 16:00:00'
)
, b as
(
    select
        t1.*
        ,ds.handover_par_cnt 员工当日交接包裹数
        ,dev.staff_num 设备登录账号数
        ,pr.pno 交接包裹单号
        ,case pi.state
            when 1 then '已揽收'
            when 2 then '运输中'
            when 3 then '派送中'
            when 4 then '已滞留'
            when 5 then '已签收'
            when 6 then '疑难件处理中'
            when 7 then '已退件'
            when 8 then '异常关闭'
            when 9 then '已撤销'
        end 交接包裹当前状态
        ,pr.routed_at
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
        ,row_number() over (partition by t1.device_id,pr.pno, pr.staff_info_id order by pr.routed_at desc) rnk
        ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
    from t t1
    left join t t2 on t2.device_id = t1.device_id and t2.rk = t1.rk + 1
    left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-12'
    left join
        (
            select
                t1.device_id
                ,count(distinct t1.staff_info_id) staff_num
            from  t t1
            group by 1
        ) dev on dev.device_id = t1.device_id
    left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(t2.登录时间, interval 8 hour)
    left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
, pr as
(
    select
        pr2.pno
        ,pr2.staff_info_id
        ,pr2.routed_at
        ,row_number() over (partition by pr2.pno order by pr2.routed_at ) rk
    from ph_staging.parcel_route pr2
    where
        pr2.routed_at >= '2023-07-11 16:00:00'
        and pr2.routed_at < '2023-07-12 16:00:00'
        and pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    )
select
    b1.*
    ,if(pr2.staff_info_id is not null, if(pr2.staff_info_id = b1.staff_info_id , '是', '否'), '' ) 包裹上一交接人是否是此人
from
    (
        select
            *
        from b b1
        where
            if(b1.sc_time is null , 1 = 1, b1.rnk = 1)
    ) b1
left join pr pr1 on pr1.pno = b1.交接包裹单号 and pr1.routed_at = b1.routed_at
left join pr pr2 on pr2.pno = pr1.pno and pr2.rk = pr1.rk - 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,dp.piece_name 片区
        ,dp.region_name 大区
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.device_id order by ldr.created_at) rk
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ss.id and dp.stat_date = date_sub(curdate(), interval 1 day)
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-12 16:00:00'
        and ldr.created_at < '2023-07-13 16:00:00'
)
, b as
(
    select
        t1.*
        ,ds.handover_par_cnt 员工当日交接包裹数
        ,dev.staff_num 设备登录账号数
        ,pr.pno 交接包裹单号
        ,case pi.state
            when 1 then '已揽收'
            when 2 then '运输中'
            when 3 then '派送中'
            when 4 then '已滞留'
            when 5 then '已签收'
            when 6 then '疑难件处理中'
            when 7 then '已退件'
            when 8 then '异常关闭'
            when 9 then '已撤销'
        end 交接包裹当前状态
        ,pr.routed_at
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
        ,row_number() over (partition by t1.device_id,pr.pno, pr.staff_info_id order by pr.routed_at desc) rnk
        ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
    from t t1
    left join t t2 on t2.device_id = t1.device_id and t2.rk = t1.rk + 1
    left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-12'
    left join
        (
            select
                t1.device_id
                ,count(distinct t1.staff_info_id) staff_num
            from  t t1
            group by 1
        ) dev on dev.device_id = t1.device_id
    left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(t2.登录时间, interval 8 hour)
    left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
, pr as
(
    select
        pr2.pno
        ,pr2.staff_info_id
        ,pr2.routed_at
        ,row_number() over (partition by pr2.pno order by pr2.routed_at ) rk
    from ph_staging.parcel_route pr2
    where
        pr2.routed_at >= '2023-07-12 16:00:00'
        and pr2.routed_at < '2023-07-13 16:00:00'
        and pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    )
select
    b1.*
    ,pr1.rk 本次交接是此包裹当天的第几次交接
    ,if(pr2.staff_info_id is not null, if(pr2.staff_info_id = b1.staff_info_id , '是', '否'), '' ) 包裹上一交接人是否是此人
from
    (
        select
            *
        from b b1
        where
            if(b1.sc_time is null , 1 = 1, b1.rnk = 1)
    ) b1
left join pr pr1 on pr1.pno = b1.交接包裹单号 and pr1.routed_at = b1.routed_at
left join pr pr2 on pr2.pno = pr1.pno and pr2.rk = pr1.rk - 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,dp.piece_name 片区
        ,dp.region_name 大区
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.device_id order by ldr.created_at) rk
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ss.id and dp.stat_date = date_sub(curdate(), interval 1 day)
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-12 16:00:00'
        and ldr.created_at < '2023-07-13 16:00:00'
)
, b as
(
    select
        t1.*
        ,ds.handover_par_cnt 员工当日交接包裹数
        ,dev.staff_num 设备登录账号数
        ,pr.pno 交接包裹单号
        ,case pi.state
            when 1 then '已揽收'
            when 2 then '运输中'
            when 3 then '派送中'
            when 4 then '已滞留'
            when 5 then '已签收'
            when 6 then '疑难件处理中'
            when 7 then '已退件'
            when 8 then '异常关闭'
            when 9 then '已撤销'
        end 交接包裹当前状态
        ,pr.routed_at
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
        ,row_number() over (partition by t1.device_id,pr.pno, pr.staff_info_id order by pr.routed_at desc) rnk
        ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
    from t t1
    left join t t2 on t2.device_id = t1.device_id and t2.rk = t1.rk + 1
    left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-13'
    left join
        (
            select
                t1.device_id
                ,count(distinct t1.staff_info_id) staff_num
            from  t t1
            group by 1
        ) dev on dev.device_id = t1.device_id
    left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(t2.登录时间, interval 8 hour)
    left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
, pr as
(
    select
        pr2.pno
        ,pr2.staff_info_id
        ,pr2.routed_at
        ,row_number() over (partition by pr2.pno order by pr2.routed_at ) rk
    from ph_staging.parcel_route pr2
    where
        pr2.routed_at >= '2023-07-12 16:00:00'
        and pr2.routed_at < '2023-07-13 16:00:00'
        and pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    )
select
    b1.*
    ,pr1.rk 本次交接是此包裹当天的第几次交接
    ,if(pr2.staff_info_id is not null, if(pr2.staff_info_id = b1.staff_info_id , '是', '否'), '' ) 包裹上一交接人是否是此人
from
    (
        select
            *
        from b b1
        where
            if(b1.sc_time is null , 1 = 1, b1.rnk = 1)
    ) b1
left join pr pr1 on pr1.pno = b1.交接包裹单号 and pr1.routed_at = b1.routed_at
left join pr pr2 on pr2.pno = pr1.pno and pr2.rk = pr1.rk - 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
        when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
        when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
        when hsi2.`state` =2 then '离职'
        when hsi2.`state` =3 then '停职'
    end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-11 16:00:00'
        and ldr.created_at < '2023-07-12 16:00:00'
)
select
    t1.*
    ,dev.staff_num 设备登录账号数
from t t1
left join
    (
        select
            t1.device_id
            ,count(distinct t1.staff_info_id) staff_num
        from  t t1
        group by 1
    ) dev on dev.device_id = t1.device_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,hsi.name staff_name
        ,hsi.formal
        ,hjt.job_name
        ,hsi.state
        ,hsi.hire_date
        ,hsi.wait_leave_state
        ,ss.name
        ,smp.name mp_name
        ,smr.name mr_name
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    left join ph_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join ph_staging.sys_manage_region smr on smr.id= ss.manage_region
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_backyard.staff_todo_list stl on hsi.staff_info_id = stl.staff_info_id
    where
        stl.staff_info_id is null
        and hsi.job_title in (13,110,1000,37) -- 仓管&快递员
        and hsi.state in (1,3)
)
select
    t1.staff_info_id 员工ID
    ,t1.staff_name 员工姓名
    ,date(t1.hire_date) 入职时间
    ,t1.job_name 职位
    ,case t1.formal
        when 1 then '正式'
        when 0 then '外协'
        when 2 then '加盟商'
        when 3 then '其他'
    end 员工属性
    ,case
        when  t1.`state`=1 and t1.`wait_leave_state` =0 then '在职'
        when  t1.`state`=1 and t1.`wait_leave_state` =1 then '待离职'
        when t1.`state` =2 then '离职'
        when t1.`state` =3 then '停职'
    end 员工状态
    ,t1.name 所属网点
    ,t1.mp_name 所属片区d
    ,t1.mr_name 所属大区

    ,swa.end_at 0711下班打卡时间
    ,swa.end_clientid 0711下班打卡客户端ID
    ,if((ad.`shift_start`<>'' or ad.`shift_end`<>''),1,0) 0711是否排班
    ,if((ad.`attendance_started_at` is not null or ad.`attendance_end_at` is not null),1,0) 0711是否出勤
    ,if(length(ad.leave_type ) > 0 , 1, 0) 0711是否请假
    ,case sa.equipment_type
        when 1 then 'kit'
        when 3 then 'backyard'
    end 0711下班打卡设备
    ,sa.version 0711下班打卡版本

    ,swa2.end_at 0712下班打卡时间
    ,swa2.end_clientid 0712下班打卡客户端ID
    ,if((ad2.`shift_start`<>'' or ad2.`shift_end`<>''),1,0) 0712是否排班
    ,if((ad2.`attendance_started_at` is not null or ad2.`attendance_end_at` is not null),1,0) 0712是否出勤
    ,if(length(ad2.leave_type ) > 0 , 1, 0)0712是否请假
    ,case sa2.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0712下班打卡设备
    ,sa2.version 0712下班打卡版本

    ,swa3.end_at 0713下班打卡时间
    ,swa3.end_clientid 0713下班打卡客户端ID
    ,if((ad3.`shift_start`<>'' or ad3.`shift_end`<>''),1,0) 0713是否排班
    ,if((ad3.`attendance_started_at` is not null or ad3.`attendance_end_at` is not null),1,0) 0713是否出勤
    ,if(length(ad3.leave_type ) > 0 , 1, 0) 0713是否请假
    ,case sa3.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0713下班打卡设备
    ,sa3.version 0713下班打卡版本

    ,swa4.end_at 0714下班打卡时间
    ,swa4.end_clientid 0714下班打卡客户端ID
    ,if((ad4.`shift_start`<>'' or ad4.`shift_end`<>''),1,0) 0714是否排班
    ,if((ad4.`attendance_started_at` is not null or ad4.`attendance_end_at` is not null),1,0) 0714是否出勤
    ,if(length(ad4.leave_type ) > 0 , 1, 0) 0714是否请假
    ,case sa4.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0714下班打卡设备
    ,sa3.version 0714下班打卡版本
from t t1
left join ph_backyard.staff_work_attendance swa on swa.staff_info_id = t1.staff_info_id and swa.attendance_date = '2023-07-11'
left join ph_staging.staff_account sa on sa.clientid = swa.end_clientid and swa.staff_info_id = sa.staff_info_id
left join ph_bi.attendance_data_v2 ad on ad.staff_info_id = t1.staff_info_id and ad.stat_date = swa.attendance_date

left join ph_backyard.staff_work_attendance swa2 on swa2.staff_info_id = t1.staff_info_id and swa2.attendance_date = '2023-07-12'
left join ph_staging.staff_account sa2 on sa2.clientid = swa2.end_clientid and swa2.staff_info_id = sa2.staff_info_id
left join ph_bi.attendance_data_v2 ad2 on ad2.staff_info_id = t1.staff_info_id and ad2.stat_date = swa2.attendance_date

left join ph_backyard.staff_work_attendance swa3 on swa3.staff_info_id = t1.staff_info_id and swa3.attendance_date = '2023-07-13'
left join ph_staging.staff_account sa3 on sa3.clientid = swa3.end_clientid and swa3.staff_info_id = sa3.staff_info_id
left join ph_bi.attendance_data_v2 ad3 on ad3.staff_info_id = t1.staff_info_id and ad3.stat_date = swa3.attendance_date

left join ph_backyard.staff_work_attendance swa4 on swa4.staff_info_id = t1.staff_info_id and swa4.attendance_date = '2023-07-14'
left join ph_staging.staff_account sa4 on sa4.clientid = swa4.end_clientid and swa4.staff_info_id = sa4.staff_info_id
left join ph_bi.attendance_data_v2 ad4 on ad4.staff_info_id = t1.staff_info_id and ad4.stat_date = swa4.attendance_date;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,hsi3.name submitter_name
    ,hjt2.job_name submitter_job
    ,ra.report_id
    ,concat(tp.cn, tp.eng) reason
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') picture
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join ph_bi.hr_staff_info hsi3 on hsi3.staff_info_id = ra.submitter_id
left join ph_bi.hr_job_title hjt2 on hjt2.id = hsi3.job_title
left join tmpale.tmp_ph_report_reason tp on tp.key = ra.reason
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id and sa.oss_bucket_type = 'REPORT_AUDIT_IMG'
where
    ra.created_at >= '2023-07-10'
    and ra.status = 2
    and ra.final_approval_time >= date_sub(curdate(), interval 11 hour)
group by 1
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,a1.id 举报记录ID
    ,a1.submitter_id 举报人工号
    ,a1.submitter_name 举报人姓名
    ,a1.submitter_job 举报人职位
    ,hsi.name 被举报人姓名
    ,date(hsi.hire_date) 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.reason 举报原因
    ,a1.remark 事情描述
    ,a1.picture 图片
    ,hsi.mobile 手机号

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,case
        when smr.name in ('Area3', 'Area6') then '彭万松'
        when smr.name in ('Area4', 'Area9') then '韩钥'
        when smr.name in ('Area7', 'Area8','Area10', 'Area11','FHome') then '张可新'
        when smr.name in ('Area1', 'Area2','Area5', 'Area12') then '李俊'
    end 负责人
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 2;
;-- -. . -..- - / . -. - .-. -.--
select
    coalesce(a2.client_name, '总计') 客户
    ,'收件人拒收' 疑难件原因
    ,a2.`昨日20-今日20单量`
    ,a2.`昨日20-今日20处理完成单量`
    ,a2.`昨日20-今日20处理及时完成单量`
from
    (
        select
            a.client_name
            ,count(a.id) '昨日20-今日20单量'
            ,count(if(a.visit_state in (3,4), a.id, null)) '昨日20-今日20处理完成单量'
            ,count(if(a.beyond_time = 'y', a.id, null)) '昨日20-今日20处理及时完成单量'
        from
            (
                select
                    vrv.link_id
                    ,bc.client_name
                    ,vrv.id
                    ,vrv.visit_state
                    ,vrv.created_at
                    ,case
                        when vrv.visit_state in (4) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 120 then 'y'
                        when vrv.visit_state in (4) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 120 then 'n'
                        when vrv.visit_state in (4) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
                        when vrv.visit_state in (4) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 240 then 'n'

                        when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
                        when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) > 240 then 'n'
                    end beyond_time
                from nl_production.violation_return_visit vrv
                join dwm.dwd_dim_bigClient bc on vrv.client_id = bc.client_id
                where
                    vrv.created_at >= date_sub('2023-07-14', interval 4 hour)
                    and vrv.created_at < date_add('2023-07-14', interval 20 hour)
                    and vrv.type = 3
            ) a
        group by 1
        with rollup
    ) a2;
;-- -. . -..- - / . -. - .-. -.--
select
    coalesce(a2.client_name, '总计') 客户
    ,'收件人拒收' 疑难件原因
    ,a2.`昨日20-今日20单量`
    ,a2.`昨日20-今日20处理完成单量`
    ,a2.`昨日20-今日20处理及时完成单量`
from
    (
        select
            a.client_name
            ,count(a.id) '昨日20-今日20单量'
            ,count(if(a.visit_state in (3,4), a.id, null)) '昨日20-今日20处理完成单量'
            ,count(if(a.beyond_time = 'y', a.id, null)) '昨日20-今日20处理及时完成单量'
        from
            (
                select
                    vrv.link_id
                    ,bc.client_name
                    ,vrv.id
                    ,vrv.visit_state
                    ,vrv.created_at
                    ,case
                        when vrv.visit_state in (4) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 120 then 'y'
                        when vrv.visit_state in (4) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 120 then 'n'
                        when vrv.visit_state in (4) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
                        when vrv.visit_state in (4) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 240 then 'n'

                        when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
                        when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) > 240 then 'n'
                    end beyond_time
                from nl_production.violation_return_visit vrv
                join dwm.dwd_dim_bigClient bc on vrv.client_id = bc.client_id
                where
                    vrv.created_at >= date_sub('2023-07-14', interval 4 hour)
                    and vrv.created_at < date_add('2023-07-14', interval 20 hour)
                    and vrv.type = 3
            ) a
        group by 1
        with rollup
    ) a2
order by 1;
;-- -. . -..- - / . -. - .-. -.--
select
                    vrv.link_id
                    ,bc.client_name
                    ,vrv.id
                    ,vrv.visit_state
                    ,vrv.created_at
                    ,vrv.updated_at
                    ,case
                        when vrv.visit_state in (4) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 120 then 'y'
                        when vrv.visit_state in (4) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 120 then 'n'
                        when vrv.visit_state in (4) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
                        when vrv.visit_state in (4) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 240 then 'n'

                        when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
                        when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) > 240 then 'n'
                    end beyond_time
                from nl_production.violation_return_visit vrv
                join dwm.dwd_dim_bigClient bc on vrv.client_id = bc.client_id
                where
                    vrv.created_at >= date_sub('2023-07-14', interval 4 hour)
                    and vrv.created_at < date_add('2023-07-14', interval 20 hour)
                    and vrv.type = 3;
;-- -. . -..- - / . -. - .-. -.--
select
                    vrv.link_id
                    ,bc.client_name
                    ,vrv.id
                    ,vrv.visit_state
                    ,vrv.created_at
                    ,vrv.updated_at
                    ,vrv.visit_num
                    ,case
                        when vrv.visit_state in (4) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 120 then 'y'
                        when vrv.visit_state in (4) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 120 then 'n'
                        when vrv.visit_state in (4) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
                        when vrv.visit_state in (4) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 240 then 'n'

                        when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
                        when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) > 240 then 'n'
                    end beyond_time
                from nl_production.violation_return_visit vrv
                join dwm.dwd_dim_bigClient bc on vrv.client_id = bc.client_id
                where
                    vrv.created_at >= date_sub('2023-07-14', interval 4 hour)
                    and vrv.created_at < date_add('2023-07-14', interval 20 hour)
                    and vrv.type = 3;
;-- -. . -..- - / . -. - .-. -.--
select
    coalesce(a2.client_name, '总计') 客户
    ,'收件人拒收' 疑难件原因
    ,a2.`昨日20-今日20单量`
    ,a2.`昨日20-今日20处理完成单量`
    ,a2.`昨日20-今日20处理及时完成单量`
from
    (
        select
            a.client_name
            ,count(a.id) '昨日20-今日20单量'
            ,count(if(a.visit_state in (3,4), a.id, null)) '昨日20-今日20处理完成单量'
            ,count(if(a.beyond_time = 'y', a.id, null)) '昨日20-今日20处理及时完成单量'
        from
            (
                select
                    vrv.link_id
                    ,bc.client_name
                    ,vrv.id
                    ,vrv.visit_state
                    ,vrv.created_at
                    ,vrv.updated_at
                    ,vrv.visit_num
                    ,case
                        when vrv.visit_state in (4) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 120 then 'y'
                        when vrv.visit_state in (4) and vrv.visit_num = 1  and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 120 then 'n'
                        when vrv.visit_state in (4) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
                        when vrv.visit_state in (4) and vrv.visit_num > 1 and timestampdiff(minute , vrv.created_at, vrv.updated_at) >= 240 then 'n'

                        when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) < 240 then 'y'
                        when vrv.visit_state in (3) and timestampdiff(minute , vrv.created_at, vrv.updated_at) > 240 then 'n'
                    end beyond_time
                from nl_production.violation_return_visit vrv
                join dwm.dwd_dim_bigClient bc on vrv.client_id = bc.client_id
                where
                    vrv.created_at >= date_sub('2023-07-14', interval 4 hour)
                    and vrv.created_at < date_add('2023-07-14', interval 20 hour)
                    and vrv.type = 3
            ) a
        group by 1
        with rollup
    ) a2
order by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    ldr.device_id
    ,ldr.staff_info_id
    ,ldr.created_at
from ph_staging.login_device_record ldr
where
    ldr.created_at >= '2023-07-12 16:00:00'
    and ldr.created_at < '2023-07-13 16:00:00'
    and ldr.staff_info_id = '122965';
;-- -. . -..- - / . -. - .-. -.--
select
    ldr.device_id
    ,ldr.staff_info_id
    ,ldr.created_at
    ,row_number() over (order by ldr.device_id) rk
from ph_staging.login_device_record ldr
where
    ldr.created_at >= '2023-07-12 16:00:00'
    and ldr.created_at < '2023-07-13 16:00:00'
    and ldr.staff_info_id = '122965';
;-- -. . -..- - / . -. - .-. -.--
select
    ldr.device_id
    ,ldr.staff_info_id
    ,ldr.created_at
    ,row_number() over (order by ldr.device_id) rk
from ph_staging.login_device_record ldr
where
    ldr.created_at >= '2023-07-12 16:00:00'
    and ldr.created_at < '2023-07-13 16:00:00'
    and ldr.device_id = '3f20427d8fc43069';
;-- -. . -..- - / . -. - .-. -.--
select
    ldr.device_id
    ,ldr.staff_info_id
    ,ldr.created_at
    ,row_number() over (order by ldr.device_id) rk
from ph_staging.login_device_record ldr
where
    ldr.created_at >= '2023-07-12 16:00:00'
    and ldr.created_at < '2023-07-13 16:00:00'
    and ldr.device_id = '942aa78a583689a9';
;-- -. . -..- - / . -. - .-. -.--
select
    ldr.device_id
    ,ldr.staff_info_id
    ,ldr.created_at
    ,row_number() over (order by ldr.staff_info_id) rk
from ph_staging.login_device_record ldr
where
    ldr.created_at >= '2023-07-12 16:00:00'
    and ldr.created_at < '2023-07-13 16:00:00'
    and ldr.device_id = '942aa78a583689a9';
;-- -. . -..- - / . -. - .-. -.--
select
    ldr.device_id
    ,ldr.staff_info_id
    ,ldr.created_at
    ,row_number() over (order by ldr.staff_info_id) rk
from ph_staging.login_device_record ldr
where
    ldr.created_at >= '2023-07-12 16:00:00'
    and ldr.created_at < '2023-07-13 16:00:00'
    and ldr.device_id = '14832000176821483200017683';
;-- -. . -..- - / . -. - .-. -.--
select
    ldr.device_id
    ,ldr.staff_info_id
    ,ldr.created_at
    ,row_number() over (order by ldr.staff_info_id) rk
from ph_staging.login_device_record ldr
where
    ldr.created_at >= '2023-07-12 16:00:00'
    and ldr.created_at < '2023-07-13 16:00:00'
    and ldr.device_id = '14832000302991483200030300';
;-- -. . -..- - / . -. - .-. -.--
    ,ldr.created_at;
;-- -. . -..- - / . -. - .-. -.--
select
    ldr.device_id
    ,ldr.staff_info_id
    ,ldr.created_at
    ,row_number() over (order by ldr.created_at) rk
from ph_staging.login_device_record ldr
where
    ldr.created_at >= '2023-07-12 16:00:00'
    and ldr.created_at < '2023-07-13 16:00:00'
    and ldr.device_id = '14832000302991483200030300';
;-- -. . -..- - / . -. - .-. -.--
select
    a.*
from
    (
        select
            ldr.device_id
            ,ldr.staff_info_id
            ,ldr.created_at
            ,row_number() over (order by ldr.created_at) rk
        from ph_staging.login_device_record ldr
        where
            ldr.created_at >= '2023-07-12 16:00:00'
            and ldr.created_at < '2023-07-13 16:00:00'
            and ldr.device_id = '14832000302991483200030300'
    ) a
group by a.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,dp.piece_name 片区
        ,dp.region_name 大区
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.staff_info_id order by ldr.created_at) rk
        ,row_number() over (order by ldr.created_at ) rn
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ss.id and dp.stat_date = date_sub(curdate(), interval 1 day)
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-12 16:00:00'
        and ldr.created_at < '2023-07-13 16:00:00'
)
, staff as
(
    select
        t1.*
        ,min(t2.登录时间) other_login_time
    from t t1
    left join t t2 on t2.device_id = t1.device_id
    where
        t2.staff_info_id != t1.staff_info_id
        and t2.登录时间 > t1.登录时间
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
)

, b as
(
    select
        t1.*
        ,ds.handover_par_cnt 员工当日交接包裹数
        ,dev.staff_num 设备登录账号数
        ,pr.pno 交接包裹单号
        ,case pi.state
            when 1 then '已揽收'
            when 2 then '运输中'
            when 3 then '派送中'
            when 4 then '已滞留'
            when 5 then '已签收'
            when 6 then '疑难件处理中'
            when 7 then '已退件'
            when 8 then '异常关闭'
            when 9 then '已撤销'
        end 交接包裹当前状态
        ,pr.routed_at
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
        ,row_number() over (partition by t1.device_id,pr.pno, pr.staff_info_id order by pr.routed_at desc) rnk
        ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
    from t t1
    left join t t2 on t2.staff_info_id = t1.staff_info_id and t2.rk = t1.rk + 1
    left join staff s2 on s2.rn = t1.rn
    left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-13'
    left join
        (
            select
                t1.device_id
                ,count(distinct t1.staff_info_id) staff_num
            from  t t1
            group by 1
        ) dev on dev.device_id = t1.device_id
    left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(least(s2.other_login_time, t2.登录时间), interval 8 hour)
    left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
, pr as
(
    select
        pr2.pno
        ,pr2.staff_info_id
        ,pr2.routed_at
        ,row_number() over (partition by pr2.pno order by pr2.routed_at ) rk
    from ph_staging.parcel_route pr2
    where
        pr2.routed_at >= '2023-07-12 16:00:00'
        and pr2.routed_at < '2023-07-13 16:00:00'
        and pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    )
select
    b1.*
    ,pr1.rk 本次交接是此包裹当天的第几次交接
    ,if(pr2.staff_info_id is not null, if(pr2.staff_info_id = b1.staff_info_id , '是', '否'), '' ) 包裹上一交接人是否是此人
from
    (
        select
            *
        from b b1
        where
            if(b1.sc_time is null , 1 = 1, b1.rnk = 1)
    ) b1
left join pr pr1 on pr1.pno = b1.交接包裹单号 and pr1.routed_at = b1.routed_at
left join pr pr2 on pr2.pno = pr1.pno and pr2.rk = pr1.rk - 1;
;-- -. . -..- - / . -. - .-. -.--
select date_sub(curdate(),interval  28 day );
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
        when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
        when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
        when hsi2.`state` =2 then '离职'
        when hsi2.`state` =3 then '停职'
    end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-11 16:00:00'
        and ldr.created_at < '2023-07-12 16:00:00'
        and ldr.device_id = '14832000302991483200030300'
)
select
    t1.*
    ,dev.staff_num 设备登录账号数
from t t1
left join
    (
        select
            t1.device_id
            ,count(distinct t1.staff_info_id) staff_num
        from  t t1
        group by 1
    ) dev on dev.device_id = t1.device_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,dp.piece_name 片区
        ,dp.region_name 大区
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.staff_info_id order by ldr.created_at) rk
        ,row_number() over (order by ldr.created_at ) rn
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ss.id and dp.stat_date = date_sub(curdate(), interval 1 day)
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-12 16:00:00'
        and ldr.created_at < '2023-07-13 16:00:00'
)
, staff as
(
    select
        t1.*
        ,min(t2.登录时间) other_login_time
    from t t1
    left join t t2 on t2.device_id = t1.device_id
    where
        t2.staff_info_id != t1.staff_info_id
        and t2.登录时间 > t1.登录时间
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
)

, b as
(
    select
        t1.*
        ,ds.handover_par_cnt 员工当日交接包裹数
        ,dev.staff_num 设备登录账号数
        ,pr.pno 交接包裹单号
        ,case pi.state
            when 1 then '已揽收'
            when 2 then '运输中'
            when 3 then '派送中'
            when 4 then '已滞留'
            when 5 then '已签收'
            when 6 then '疑难件处理中'
            when 7 then '已退件'
            when 8 then '异常关闭'
            when 9 then '已撤销'
        end 交接包裹当前状态
        ,pr.routed_at
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
        ,row_number() over (partition by t1.device_id,pr.pno, pr.staff_info_id order by pr.routed_at desc) rnk
        ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
    from t t1
    left join t t2 on t2.staff_info_id = t1.staff_info_id and t2.rk = t1.rk + 1
    left join staff s2 on s2.rn = t1.rn
    left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-13'
    left join
        (
            select
                t1.device_id
                ,count(distinct t1.staff_info_id) staff_num
            from  t t1
            group by 1
        ) dev on dev.device_id = t1.device_id
    left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(least(s2.other_login_time, t2.登录时间), interval 8 hour)
    left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
, pr as
(
    select
        pr2.pno
        ,pr2.staff_info_id
        ,pr2.routed_at
        ,row_number() over (partition by pr2.pno order by pr2.routed_at ) rk
    from ph_staging.parcel_route pr2
    where
        pr2.routed_at >= '2023-07-12 16:00:00'
        and pr2.routed_at < '2023-07-13 16:00:00'
        and pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    )
select
    b1.*
    ,pr1.rk 本次交接是此包裹当天的第几次交接
    ,if(pr2.staff_info_id is not null, if(pr2.staff_info_id = b1.staff_info_id , '是', '否'), '' ) 包裹上一交接人是否是此人
from
    (
        select
            *
        from b b1
        where
            if(b1.sc_time is null , 1 = 1, b1.rnk = 1)
    ) b1
left join pr pr1 on pr1.pno = b1.交接包裹单号 and pr1.routed_at = b1.routed_at
left join pr pr2 on pr2.pno = pr1.pno and pr2.rk = pr1.rk - 1
where
    b1.归属网点 = 'LAU_SP';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
        when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
        when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
        when hsi2.`state` =2 then '离职'
        when hsi2.`state` =3 then '停职'
    end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-12 16:00:00'
        and ldr.created_at < '2023-07-13 16:00:00'
)
select
    t1.*
    ,dev.staff_num 设备登录账号数
from t t1
left join
    (
        select
            t1.device_id
            ,count(distinct t1.staff_info_id) staff_num
        from  t t1
        group by 1
    ) dev on dev.device_id = t1.device_id
where
    t1.归属网点 = 'LAU_SP';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
        when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
        when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
        when hsi2.`state` =2 then '离职'
        when hsi2.`state` =3 then '停职'
    end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-12 16:00:00'
        and ldr.created_at < '2023-07-13 16:00:00'
)
select
    t1.*
    ,dev.staff_num 设备登录账号数
from t t1
left join
    (
        select
            t1.device_id
            ,count(distinct t1.staff_info_id) staff_num
        from  t t1
        group by 1
    ) dev on dev.device_id = t1.device_id
where
    t1.归属网点 = 'RBL_SP';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,dp.piece_name 片区
        ,dp.region_name 大区
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.staff_info_id order by ldr.created_at) rk
        ,row_number() over (order by ldr.created_at ) rn
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ss.id and dp.stat_date = date_sub(curdate(), interval 1 day)
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-12 16:00:00'
        and ldr.created_at < '2023-07-13 16:00:00'
)
, staff as
(
    select
        t1.*
        ,min(t2.登录时间) other_login_time
    from t t1
    left join t t2 on t2.device_id = t1.device_id
    where
        t2.staff_info_id != t1.staff_info_id
        and t2.登录时间 > t1.登录时间
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
)

, b as
(
    select
        t1.*
        ,ds.handover_par_cnt 员工当日交接包裹数
        ,dev.staff_num 设备登录账号数
        ,pr.pno 交接包裹单号
        ,case pi.state
            when 1 then '已揽收'
            when 2 then '运输中'
            when 3 then '派送中'
            when 4 then '已滞留'
            when 5 then '已签收'
            when 6 then '疑难件处理中'
            when 7 then '已退件'
            when 8 then '异常关闭'
            when 9 then '已撤销'
        end 交接包裹当前状态
        ,pr.routed_at
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
        ,row_number() over (partition by t1.device_id,pr.pno, pr.staff_info_id order by pr.routed_at desc) rnk
        ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
    from t t1
    left join t t2 on t2.staff_info_id = t1.staff_info_id and t2.rk = t1.rk + 1
    left join staff s2 on s2.rn = t1.rn
    left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-13'
    left join
        (
            select
                t1.device_id
                ,count(distinct t1.staff_info_id) staff_num
            from  t t1
            group by 1
        ) dev on dev.device_id = t1.device_id
    left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(least(s2.other_login_time, t2.登录时间), interval 8 hour)
    left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
, pr as
(
    select
        pr2.pno
        ,pr2.staff_info_id
        ,pr2.routed_at
        ,row_number() over (partition by pr2.pno order by pr2.routed_at ) rk
    from ph_staging.parcel_route pr2
    where
        pr2.routed_at >= '2023-07-12 16:00:00'
        and pr2.routed_at < '2023-07-13 16:00:00'
        and pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    )
select
    b1.*
    ,pr1.rk 本次交接是此包裹当天的第几次交接
    ,if(pr2.staff_info_id is not null, if(pr2.staff_info_id = b1.staff_info_id , '是', '否'), '' ) 包裹上一交接人是否是此人
from
    (
        select
            *
        from b b1
        where
            if(b1.sc_time is null , 1 = 1, b1.rnk = 1)
    ) b1
left join pr pr1 on pr1.pno = b1.交接包裹单号 and pr1.routed_at = b1.routed_at
left join pr pr2 on pr2.pno = pr1.pno and pr2.rk = pr1.rk - 1
where
    b1.归属网点 = 'RBL_SP';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,dp.piece_name 片区
        ,dp.region_name 大区
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.staff_info_id order by ldr.created_at) rk
        ,row_number() over (order by ldr.created_at ) rn
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ss.id and dp.stat_date = date_sub(curdate(), interval 1 day)
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-12 16:00:00'
        and ldr.created_at < '2023-07-13 16:00:00'
)
, staff as
(
    select
        t1.*
        ,min(t2.登录时间) other_login_time
    from t t1
    left join t t2 on t2.device_id = t1.device_id
    where
        t2.staff_info_id != t1.staff_info_id
        and t2.登录时间 > t1.登录时间
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
)

, b as
(
    select
        t1.*
        ,ds.handover_par_cnt 员工当日交接包裹数
        ,dev.staff_num 设备登录账号数
        ,pr.pno 交接包裹单号
        ,case pi.state
            when 1 then '已揽收'
            when 2 then '运输中'
            when 3 then '派送中'
            when 4 then '已滞留'
            when 5 then '已签收'
            when 6 then '疑难件处理中'
            when 7 then '已退件'
            when 8 then '异常关闭'
            when 9 then '已撤销'
        end 交接包裹当前状态
        ,pr.routed_at
        ,s2.other_login_time
        ,t2.登录时间
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
        ,row_number() over (partition by t1.device_id,pr.pno, pr.staff_info_id order by pr.routed_at desc) rnk
        ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
    from t t1
    left join t t2 on t2.staff_info_id = t1.staff_info_id and t2.rk = t1.rk + 1
    left join staff s2 on s2.rn = t1.rn
    left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-13'
    left join
        (
            select
                t1.device_id
                ,count(distinct t1.staff_info_id) staff_num
            from  t t1
            group by 1
        ) dev on dev.device_id = t1.device_id
    left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(least(s2.other_login_time, t2.登录时间), interval 8 hour)
    left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
, pr as
(
    select
        pr2.pno
        ,pr2.staff_info_id
        ,pr2.routed_at
        ,row_number() over (partition by pr2.pno order by pr2.routed_at ) rk
    from ph_staging.parcel_route pr2
    where
        pr2.routed_at >= '2023-07-12 16:00:00'
        and pr2.routed_at < '2023-07-13 16:00:00'
        and pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    )
select
    b1.*
    ,pr1.rk 本次交接是此包裹当天的第几次交接
    ,if(pr2.staff_info_id is not null, if(pr2.staff_info_id = b1.staff_info_id , '是', '否'), '' ) 包裹上一交接人是否是此人
from
    (
        select
            *
        from b b1
        where
            if(b1.sc_time is null , 1 = 1, b1.rnk = 1)
    ) b1
left join pr pr1 on pr1.pno = b1.交接包裹单号 and pr1.routed_at = b1.routed_at
left join pr pr2 on pr2.pno = pr1.pno and pr2.rk = pr1.rk - 1
where
    b1.归属网点 = 'RBL_SP';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,dp.piece_name 片区
        ,dp.region_name 大区
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.staff_info_id order by ldr.created_at) rk
        ,row_number() over (order by ldr.created_at ) rn
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ss.id and dp.stat_date = date_sub(curdate(), interval 1 day)
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-12 16:00:00'
        and ldr.created_at < '2023-07-13 16:00:00'
)
, staff as
(
    select
        t1.*
        ,min(t2.登录时间) other_login_time
    from t t1
    left join t t2 on t2.device_id = t1.device_id
    where
        t2.staff_info_id != t1.staff_info_id
        and t2.登录时间 > t1.登录时间
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
)

, b as
(
    select
        t1.*
        ,ds.handover_par_cnt 员工当日交接包裹数
        ,dev.staff_num 设备登录账号数
        ,pr.pno 交接包裹单号
        ,case pi.state
            when 1 then '已揽收'
            when 2 then '运输中'
            when 3 then '派送中'
            when 4 then '已滞留'
            when 5 then '已签收'
            when 6 then '疑难件处理中'
            when 7 then '已退件'
            when 8 then '异常关闭'
            when 9 then '已撤销'
        end 交接包裹当前状态
        ,pr.routed_at
        ,s2.other_login_time
        ,t2.登录时间 t2_登录时间
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
        ,row_number() over (partition by t1.device_id,pr.pno, pr.staff_info_id order by pr.routed_at desc) rnk
        ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
    from t t1
    left join t t2 on t2.staff_info_id = t1.staff_info_id and t2.rk = t1.rk + 1
    left join staff s2 on s2.rn = t1.rn
    left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-13'
    left join
        (
            select
                t1.device_id
                ,count(distinct t1.staff_info_id) staff_num
            from  t t1
            group by 1
        ) dev on dev.device_id = t1.device_id
    left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(least(s2.other_login_time, t2.登录时间), interval 8 hour)
    left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
, pr as
(
    select
        pr2.pno
        ,pr2.staff_info_id
        ,pr2.routed_at
        ,row_number() over (partition by pr2.pno order by pr2.routed_at ) rk
    from ph_staging.parcel_route pr2
    where
        pr2.routed_at >= '2023-07-12 16:00:00'
        and pr2.routed_at < '2023-07-13 16:00:00'
        and pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    )
select
    b1.*
    ,pr1.rk 本次交接是此包裹当天的第几次交接
    ,if(pr2.staff_info_id is not null, if(pr2.staff_info_id = b1.staff_info_id , '是', '否'), '' ) 包裹上一交接人是否是此人
from
    (
        select
            *
        from b b1
        where
            if(b1.sc_time is null , 1 = 1, b1.rnk = 1)
    ) b1
left join pr pr1 on pr1.pno = b1.交接包裹单号 and pr1.routed_at = b1.routed_at
left join pr pr2 on pr2.pno = pr1.pno and pr2.rk = pr1.rk - 1
where
    b1.归属网点 = 'RBL_SP';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,dp.piece_name 片区
        ,dp.region_name 大区
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.staff_info_id order by ldr.created_at) rk
        ,row_number() over (order by ldr.created_at ) rn
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ss.id and dp.stat_date = date_sub(curdate(), interval 1 day)
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-12 16:00:00'
        and ldr.created_at < '2023-07-13 16:00:00'
)
, staff as
(
    select
        t1.*
        ,min(t2.登录时间) other_login_time
    from t t1
    left join t t2 on t2.device_id = t1.device_id
    where
        t2.staff_info_id != t1.staff_info_id
        and t2.登录时间 > t1.登录时间
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
)

, b as
(
    select
        t1.*
        ,ds.handover_par_cnt 员工当日交接包裹数
        ,dev.staff_num 设备登录账号数
        ,pr.pno 交接包裹单号
        ,case pi.state
            when 1 then '已揽收'
            when 2 then '运输中'
            when 3 then '派送中'
            when 4 then '已滞留'
            when 5 then '已签收'
            when 6 then '疑难件处理中'
            when 7 then '已退件'
            when 8 then '异常关闭'
            when 9 then '已撤销'
        end 交接包裹当前状态
        ,pr.routed_at
        ,s2.other_login_time
        ,t2.登录时间 t2_登录时间
        ,least(s2.other_login_time, t2.登录时间) 最小时间
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
        ,row_number() over (partition by t1.device_id,pr.pno, pr.staff_info_id order by pr.routed_at desc) rnk
        ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
    from t t1
    left join t t2 on t2.staff_info_id = t1.staff_info_id and t2.rk = t1.rk + 1
    left join staff s2 on s2.rn = t1.rn
    left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-13'
    left join
        (
            select
                t1.device_id
                ,count(distinct t1.staff_info_id) staff_num
            from  t t1
            group by 1
        ) dev on dev.device_id = t1.device_id
    left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(least(s2.other_login_time, t2.登录时间), interval 8 hour)
    left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
, pr as
(
    select
        pr2.pno
        ,pr2.staff_info_id
        ,pr2.routed_at
        ,row_number() over (partition by pr2.pno order by pr2.routed_at ) rk
    from ph_staging.parcel_route pr2
    where
        pr2.routed_at >= '2023-07-12 16:00:00'
        and pr2.routed_at < '2023-07-13 16:00:00'
        and pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    )
select
    b1.*
    ,pr1.rk 本次交接是此包裹当天的第几次交接
    ,if(pr2.staff_info_id is not null, if(pr2.staff_info_id = b1.staff_info_id , '是', '否'), '' ) 包裹上一交接人是否是此人
from
    (
        select
            *
        from b b1
        where
            if(b1.sc_time is null , 1 = 1, b1.rnk = 1)
    ) b1
left join pr pr1 on pr1.pno = b1.交接包裹单号 and pr1.routed_at = b1.routed_at
left join pr pr2 on pr2.pno = pr1.pno and pr2.rk = pr1.rk - 1
where
    b1.归属网点 = 'RBL_SP';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,dp.piece_name 片区
        ,dp.region_name 大区
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.staff_info_id order by ldr.created_at) rk
        ,row_number() over (order by ldr.created_at ) rn
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ss.id and dp.stat_date = date_sub(curdate(), interval 1 day)
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-13 16:00:00'
        and ldr.created_at < '2023-07-14 16:00:00'
)
, staff as
(
    select
        t1.*
        ,min(t2.登录时间) other_login_time
    from t t1
    left join t t2 on t2.device_id = t1.device_id
    where
        t2.staff_info_id != t1.staff_info_id
        and t2.登录时间 > t1.登录时间
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
)

, b as
(
    select
        t1.*
        ,ds.handover_par_cnt 员工当日交接包裹数
        ,dev.staff_num 设备登录账号数
        ,pr.pno 交接包裹单号
        ,case pi.state
            when 1 then '已揽收'
            when 2 then '运输中'
            when 3 then '派送中'
            when 4 then '已滞留'
            when 5 then '已签收'
            when 6 then '疑难件处理中'
            when 7 then '已退件'
            when 8 then '异常关闭'
            when 9 then '已撤销'
        end 交接包裹当前状态
        ,pr.routed_at
        ,s2.other_login_time
        ,t2.登录时间 t2_登录时间
        ,least(s2.other_login_time, t2.登录时间) 最小时间
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
        ,row_number() over (partition by t1.device_id,pr.pno, pr.staff_info_id order by pr.routed_at desc) rnk
        ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
    from t t1
    left join t t2 on t2.staff_info_id = t1.staff_info_id and t2.rk = t1.rk + 1
    left join staff s2 on s2.rn = t1.rn
    left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-14'
    left join
        (
            select
                t1.device_id
                ,count(distinct t1.staff_info_id) staff_num
            from  t t1
            group by 1
        ) dev on dev.device_id = t1.device_id
    left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(least(s2.other_login_time, t2.登录时间), interval 8 hour)
    left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
, pr as
(
    select
        pr2.pno
        ,pr2.staff_info_id
        ,pr2.routed_at
        ,row_number() over (partition by pr2.pno order by pr2.routed_at ) rk
    from ph_staging.parcel_route pr2
    where
        pr2.routed_at >= '2023-07-13 16:00:00'
        and pr2.routed_at < '2023-07-14 16:00:00'
        and pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    )
select
    b1.*
    ,pr1.rk 本次交接是此包裹当天的第几次交接
    ,if(pr2.staff_info_id is not null, if(pr2.staff_info_id = b1.staff_info_id , '是', '否'), '' ) 包裹上一交接人是否是此人
from
    (
        select
            *
        from b b1
        where
            if(b1.sc_time is null , 1 = 1, b1.rnk = 1)
    ) b1
left join pr pr1 on pr1.pno = b1.交接包裹单号 and pr1.routed_at = b1.routed_at
left join pr pr2 on pr2.pno = pr1.pno and pr2.rk = pr1.rk - 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
        when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
        when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
        when hsi2.`state` =2 then '离职'
        when hsi2.`state` =3 then '停职'
    end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-13 16:00:00'
        and ldr.created_at < '2023-07-14 16:00:00'
)
select
    t1.*
    ,dev.staff_num 设备登录账号数
from t t1
left join
    (
        select
            t1.device_id
            ,count(distinct t1.staff_info_id) staff_num
        from  t t1
        group by 1
    ) dev on dev.device_id = t1.device_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
        when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
        when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
        when hsi2.`state` =2 then '离职'
        when hsi2.`state` =3 then '停职'
    end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-13 16:00:00'
        and ldr.created_at < '2023-07-14 16:00:00'
)
select
    t1.*
    ,dev.staff_num 设备登录账号数
    ,if(stl.staff_info_id is null, '否', '是') 是否短信验证
from t t1
left join
    (
        select
            t1.device_id
            ,count(distinct t1.staff_info_id) staff_num
        from  t t1
        group by 1
    ) dev on dev.device_id = t1.device_id
left join ph_backyard.staff_todo_list stl on t1.staff_info_id = stl.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
select
    dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,plt.pno 运单
    ,plt.created_at 任务创建时间
    ,plt.parcel_created_at 包裹揽收时间
    ,ddd.CN_element 最后有效路由
    ,plt.last_valid_routed_at 最后有效路由操作时间
    ,plt.last_valid_staff_info_id 最后有效路由操作员工
    ,ss.name 最后有效路由操作网点
from ph_bi.parcel_lose_task plt
left join ph_bi.parcel_detail pd on pd.pno = plt.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pd.resp_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join dwm.dwd_dim_dict ddd on ddd.element = plt.last_valid_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = plt.last_valid_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
where
    plt.source in (3,33)
    and plt.state in (1,2,3,4);
;-- -. . -..- - / . -. - .-. -.--
select
    dp.store_name 网点Branch
    ,dp.piece_name 片区District
    ,dp.region_name 大区Area
    ,plt.pno 运单Tracking_Number
    ,plt.created_at 任务创建时间Task_Generation_time
    ,plt.parcel_created_at 包裹揽收时间Receive_time
    ,ddd.CN_element 最后有效路由Last_effective_route
    ,plt.last_valid_routed_at 最后有效路由操作时间Last_effective_routing_time
    ,plt.last_valid_staff_info_id 最后有效路由操作员工Last_effective_route_operate_id
    ,ss.name 最后有效路由操作网点Last_operate_branch
from ph_bi.parcel_lose_task plt
left join ph_bi.parcel_detail pd on pd.pno = plt.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pd.resp_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join dwm.dwd_dim_dict ddd on ddd.element = plt.last_valid_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = plt.last_valid_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
where
    plt.source in (3,33)
    and plt.state in (1,2,3,4);
;-- -. . -..- - / . -. - .-. -.--
select
    dp.store_name 网点Branch
    ,dp.piece_name 片区District
    ,dp.region_name 大区Area
    ,plt.pno 运单Tracking_Number
    ,plt.created_at 任务创建时间Task_Generation_time
    ,plt.parcel_created_at 包裹揽收时间Receive_time
    ,concat(ddd.element, ddd.CN_element) 最后有效路由Last_effective_route
    ,plt.last_valid_routed_at 最后有效路由操作时间Last_effective_routing_time
    ,plt.last_valid_staff_info_id 最后有效路由操作员工Last_effective_route_operate_id
    ,ss.name 最后有效路由操作网点Last_operate_branch
from ph_bi.parcel_lose_task plt
left join ph_bi.parcel_detail pd on pd.pno = plt.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = pd.resp_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
left join dwm.dwd_dim_dict ddd on ddd.element = plt.last_valid_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
left join dwm.dim_ph_sys_store_rd dp2 on dp2.store_id = plt.last_valid_store_id and dp2.stat_date = date_sub(curdate(), interval 1 day)
left join ph_staging.sys_store ss on ss.id = plt.last_valid_store_id
where
    plt.source in (3,33)
    and plt.state in (1,2,3,4);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,hsi.name staff_name
        ,hsi.formal
        ,hjt.job_name
        ,hsi.state
        ,hsi.hire_date
        ,hsi.wait_leave_state
        ,ss.name
        ,smp.name mp_name
        ,smr.name mr_name
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    left join ph_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join ph_staging.sys_manage_region smr on smr.id= ss.manage_region
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_backyard.staff_todo_list stl on hsi.staff_info_id = stl.staff_info_id
    where
        stl.staff_info_id is null
        and hsi.job_title in (13,110,1000,37) -- 仓管&快递员
        and hsi.state in (1,3)
)
select
    t1.staff_info_id 员工ID
    ,t1.staff_name 员工姓名
    ,date(t1.hire_date) 入职时间
    ,t1.job_name 职位
    ,case t1.formal
        when 1 then '正式'
        when 0 then '外协'
        when 2 then '加盟商'
        when 3 then '其他'
    end 员工属性
    ,case
        when  t1.`state`=1 and t1.`wait_leave_state` =0 then '在职'
        when  t1.`state`=1 and t1.`wait_leave_state` =1 then '待离职'
        when t1.`state` =2 then '离职'
        when t1.`state` =3 then '停职'
    end 员工状态
    ,t1.name 所属网点
    ,t1.mp_name 所属片区d
    ,t1.mr_name 所属大区
    ,sa.version 员工打卡客户端最新版本

    ,swa.end_at 0711下班打卡时间
    ,swa.end_clientid 0711下班打卡设备id
    ,if((ad.`shift_start`<>'' or ad.`shift_end`<>''),1,0) 0711是否排班
    ,if((ad.`attendance_started_at` is not null or ad.`attendance_end_at` is not null),1,0) 0711是否出勤
    ,if(length(ad.leave_type ) > 0 , 1, 0) 0711是否请假
    ,case sa.equipment_type
        when 1 then 'kit'
        when 3 then 'backyard'
    end 0711下班打卡设备

    ,swa2.end_at 0712下班打卡时间
    ,swa2.end_clientid 0712下班打卡设备id
    ,if((ad2.`shift_start`<>'' or ad2.`shift_end`<>''),1,0) 0712是否排班
    ,if((ad2.`attendance_started_at` is not null or ad2.`attendance_end_at` is not null),1,0) 0712是否出勤
    ,if(length(ad2.leave_type ) > 0 , 1, 0)0712是否请假
    ,case sa2.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0712下班打卡设备

    ,swa3.end_at 0713下班打卡时间
    ,swa3.end_clientid 0713下班打卡设备id
    ,if((ad3.`shift_start`<>'' or ad3.`shift_end`<>''),1,0) 0713是否排班
    ,if((ad3.`attendance_started_at` is not null or ad3.`attendance_end_at` is not null),1,0) 0713是否出勤
    ,if(length(ad3.leave_type ) > 0 , 1, 0) 0713是否请假
    ,case sa3.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0713下班打卡设备

    ,swa4.end_at 0714下班打卡时间
    ,swa4.end_clientid 0714下班打卡设备id
    ,if((ad4.`shift_start`<>'' or ad4.`shift_end`<>''),1,0) 0714是否排班
    ,if((ad4.`attendance_started_at` is not null or ad4.`attendance_end_at` is not null),1,0) 0714是否出勤
    ,if(length(ad4.leave_type ) > 0 , 1, 0) 0714是否请假
    ,case sa4.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0714下班打卡设备
from t t1
left join ph_backyard.staff_work_attendance swa on swa.staff_info_id = t1.staff_info_id and swa.attendance_date = '2023-07-11'
left join ph_staging.staff_account sa on sa.clientid = swa.end_clientid and swa.staff_info_id = sa.staff_info_id
left join ph_bi.attendance_data_v2 ad on ad.staff_info_id = t1.staff_info_id and ad.stat_date = swa.attendance_date

left join ph_backyard.staff_work_attendance swa2 on swa2.staff_info_id = t1.staff_info_id and swa2.attendance_date = '2023-07-12'
left join ph_staging.staff_account sa2 on sa2.clientid = swa2.end_clientid and swa2.staff_info_id = sa2.staff_info_id
left join ph_bi.attendance_data_v2 ad2 on ad2.staff_info_id = t1.staff_info_id and ad2.stat_date = swa2.attendance_date

left join ph_backyard.staff_work_attendance swa3 on swa3.staff_info_id = t1.staff_info_id and swa3.attendance_date = '2023-07-13'
left join ph_staging.staff_account sa3 on sa3.clientid = swa3.end_clientid and swa3.staff_info_id = sa3.staff_info_id
left join ph_bi.attendance_data_v2 ad3 on ad3.staff_info_id = t1.staff_info_id and ad3.stat_date = swa3.attendance_date

left join ph_backyard.staff_work_attendance swa4 on swa4.staff_info_id = t1.staff_info_id and swa4.attendance_date = '2023-07-14'
left join ph_staging.staff_account sa4 on sa4.clientid = swa4.end_clientid and swa4.staff_info_id = sa4.staff_info_id
left join ph_bi.attendance_data_v2 ad4 on ad4.staff_info_id = t1.staff_info_id and ad4.stat_date = swa4.attendance_date;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,hsi.name staff_name
        ,hsi.formal
        ,hjt.job_name
        ,hsi.state
        ,hsi.hire_date
        ,hsi.wait_leave_state
        ,ss.name
        ,smp.name mp_name
        ,smr.name mr_name
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    left join ph_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join ph_staging.sys_manage_region smr on smr.id= ss.manage_region
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_backyard.staff_todo_list stl on hsi.staff_info_id = stl.staff_info_id
    where
        stl.staff_info_id is null
        and hsi.job_title in (13,110,1000,37) -- 仓管&快递员
        and hsi.state in (1,3)
)
select
    t1.staff_info_id 员工ID
    ,t1.staff_name 员工姓名
    ,date(t1.hire_date) 入职时间
    ,t1.job_name 职位
    ,case t1.formal
        when 1 then '正式'
        when 0 then '外协'
        when 2 then '加盟商'
        when 3 then '其他'
    end 员工属性
    ,case
        when  t1.`state`=1 and t1.`wait_leave_state` =0 then '在职'
        when  t1.`state`=1 and t1.`wait_leave_state` =1 then '待离职'
        when t1.`state` =2 then '离职'
        when t1.`state` =3 then '停职'
    end 员工状态
    ,t1.name 所属网点
    ,t1.mp_name 所属片区d
    ,t1.mr_name 所属大区
    ,sa5.version 员工kit最新版本
    ,sa6.version 员工backyard最新版本


    ,swa.end_at 0711下班打卡时间
    ,swa.end_clientid 0711下班打卡设备id
    ,if((ad.`shift_start`<>'' or ad.`shift_end`<>''),1,0) 0711是否排班
    ,if((ad.`attendance_started_at` is not null or ad.`attendance_end_at` is not null),1,0) 0711是否出勤
    ,if(length(ad.leave_type ) > 0 , 1, 0) 0711是否请假
    ,case sa.equipment_type
        when 1 then 'kit'
        when 3 then 'backyard'
    end 0711下班打卡设备

    ,swa2.end_at 0712下班打卡时间
    ,swa2.end_clientid 0712下班打卡设备id
    ,if((ad2.`shift_start`<>'' or ad2.`shift_end`<>''),1,0) 0712是否排班
    ,if((ad2.`attendance_started_at` is not null or ad2.`attendance_end_at` is not null),1,0) 0712是否出勤
    ,if(length(ad2.leave_type ) > 0 , 1, 0)0712是否请假
    ,case sa2.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0712下班打卡设备

    ,swa3.end_at 0713下班打卡时间
    ,swa3.end_clientid 0713下班打卡设备id
    ,if((ad3.`shift_start`<>'' or ad3.`shift_end`<>''),1,0) 0713是否排班
    ,if((ad3.`attendance_started_at` is not null or ad3.`attendance_end_at` is not null),1,0) 0713是否出勤
    ,if(length(ad3.leave_type ) > 0 , 1, 0) 0713是否请假
    ,case sa3.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0713下班打卡设备

    ,swa4.end_at 0714下班打卡时间
    ,swa4.end_clientid 0714下班打卡设备id
    ,if((ad4.`shift_start`<>'' or ad4.`shift_end`<>''),1,0) 0714是否排班
    ,if((ad4.`attendance_started_at` is not null or ad4.`attendance_end_at` is not null),1,0) 0714是否出勤
    ,if(length(ad4.leave_type ) > 0 , 1, 0) 0714是否请假
    ,case sa4.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0714下班打卡设备
from t t1
left join ph_backyard.staff_work_attendance swa on swa.staff_info_id = t1.staff_info_id and swa.attendance_date = '2023-07-11'
left join ph_staging.staff_account sa on sa.clientid = swa.end_clientid and swa.staff_info_id = sa.staff_info_id
left join ph_bi.attendance_data_v2 ad on ad.staff_info_id = t1.staff_info_id and ad.stat_date = swa.attendance_date

left join ph_backyard.staff_work_attendance swa2 on swa2.staff_info_id = t1.staff_info_id and swa2.attendance_date = '2023-07-12'
left join ph_staging.staff_account sa2 on sa2.clientid = swa2.end_clientid and swa2.staff_info_id = sa2.staff_info_id
left join ph_bi.attendance_data_v2 ad2 on ad2.staff_info_id = t1.staff_info_id and ad2.stat_date = swa2.attendance_date

left join ph_backyard.staff_work_attendance swa3 on swa3.staff_info_id = t1.staff_info_id and swa3.attendance_date = '2023-07-13'
left join ph_staging.staff_account sa3 on sa3.clientid = swa3.end_clientid and swa3.staff_info_id = sa3.staff_info_id
left join ph_bi.attendance_data_v2 ad3 on ad3.staff_info_id = t1.staff_info_id and ad3.stat_date = swa3.attendance_date

left join ph_backyard.staff_work_attendance swa4 on swa4.staff_info_id = t1.staff_info_id and swa4.attendance_date = '2023-07-14'
left join ph_staging.staff_account sa4 on sa4.clientid = swa4.end_clientid and swa4.staff_info_id = sa4.staff_info_id
left join ph_bi.attendance_data_v2 ad4 on ad4.staff_info_id = t1.staff_info_id and ad4.stat_date = swa4.attendance_date

left join ph_staging.staff_account sa5 on sa5.staff_info_id = t1.staff_info_id and sa5.equipment_type = 1-- kit
left join ph_staging.staff_account sa6 on sa6.staff_info_id = t1.staff_info_id and sa6.equipment_type = 3;
;-- -. . -..- - / . -. - .-. -.--
select
    a.pno
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,dp.store_name 最后一个有效路由的网点
    ,dp.region_name 大区
    ,dp.piece_name 片区
from
    (
        select
            pr.pno
            ,pr.routed_at
            ,pr.store_id
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from ph_staging.parcel_route pr
        join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action' and ddd.remark = 'valid'
        where
            pr.pno in ('PT1911222CJC3AG','PT6116222E2N6AL','PT1220222EH99AD','PT2102222F3T8AH','PT0902222FD17AP','PT1803222FBB7BR','PT1731222FGV1AG','PT1806222G3N2BL','PT1408222G4G4AY','PT1105222FPN5AD','PT3421222GJM0AD','PT1404222HTZ6AB','PT6120222HFM7GT','PT8015222HFY5AX','PT6118222HH45AE','PT1507222JAF2AG','PT0424222JHR4CM','PT6125222JRM2AT','PT1329222K868AA','PT1928222KG86AF','PT4025222JW09AQ','PT2203222KWB5BP','PT1502222MGH5AG','PT6126222CXF1AG','PT2102222DAJ7AK','PT2207222EH98BS','PT6101222ET40CU','PT2102222F3Q0AH','PT6118222EMB5AV','PT0735222F848AX','PT6118222FYS2BB','PT1409222G6S8AL','PT1502222GA72AN','PT1308222GF20AK','PT6120222GK88GT','PT2916222G003BJ','PT6402222GMX4BZ','PT1822222G7D7AB','PT2105222GYV4AC','PT1608222GG99AC','PT2105222GNM5AA','PT6130222GTP1AI','PT1928222GU51AB','PT0708222HJ12BM','PT1410222HQK6AD','PT3307222HS12AV','PT2018222HBZ9AQ','PT2705222J6Z8AL','PT2039222KMT0AE','PT1407222K135AE','PT1110222K7X9AM','PT1716222KQ89AU','PT1104222MBX8AX','PT1222222MEJ2AV','PT0408222MKM6AG','PT0430222MK98AN','PT1606222M6A3AC','PT0424222MVT8BB','PT1606222M9A1AC','PT6130222M9Z7AP','PT1817222MC91AA','PT1317222MJP9BB')
    ) a
left join ph_staging.parcel_info pi on pi.pno = a.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a.store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
where
    a.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    am.pno
    ,ss.name 目的地网点
from ph_bi.abnormal_message am
left join ph_staging.parcel_info pi on am.pno  = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
where
    am.created_at > '2023-07-01'
    and am.isdel = 0
    and am.isappeal != 5
    and am.punish_category = 34
    and pi.dst_store_id != 'PH36100100';
;-- -. . -..- - / . -. - .-. -.--
select
    am.pno
    ,ss.name 目的地网点
from ph_bi.abnormal_message am
left join ph_staging.parcel_info pi on am.pno  = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
where
    am.created_at > '2023-07-01'
    and am.isdel = 0
    and am.isappeal != 5
    and am.punish_category = 34
    and pi.dst_store_id != 'PH36100100'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
            pr.state
            ,pr.pno
            ,pr.routed_at
            ,row_number() over (partition by pr.pno order by pr.routed_at) rk
        from ph_staging.parcel_route pr
        join
            (
                select
                    plt.pno
                from ph_bi.parcel_lose_task plt
                where
                    plt.state = 6
                group by 1
            ) plt on plt.pno = pr.pno
        where
            pr.routed_at > date_sub(date_sub(curdate(), interval 7 day), interval  8 hour)
)
select
    a.pno
from
    (
        select
            t1.*
            ,t2.state t2_state
        from
            (
                select
                    t1.*
                from t t1
                where
                    t1.state = 2
                    and t1.routed_at > date_sub(curdate(), interval 8 hour)
            ) t1
        left join t t2 on t2.pno = t1.pno and t2.rk = t1.rk - 1
    ) a
where
    a.t2_state = 8
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    am.pno
    ,ss.name 目的地网点
from ph_bi.abnormal_message am
left join ph_staging.parcel_info pi on am.pno  = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.dst_store_id
where
    am.abnormal_time > '2023-07-01'
    and am.isdel = 0
    and am.isappeal != 5
    and am.punish_category = 34
    and pi.dst_store_id != 'PH36100100'
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with p as
(
    select
        pr.pno
        ,count(pr.id) pri_num
    from ph_staging.parcel_route pr
    where
        pr.pno in ('P02151SMA10AC','P02151SM9ZRAC','P02151SM9PSAG','P02081SM9JVAC','P02151SM9CZAC','P02081SM9C3AC','P02151SM9BSAC','P02081SM9BRAC','P02151SM9AYAC','P02151SM9AVAC','P02151SM9A9AC','P02151SM998AC','P02151SM96VAC','P02151SM926AC','P02081SM8Z1AC','P02151SM8TAAC','P02081SM8MPAC')
        and pr.route_action = 'PRINTING'
    group by 1
)

select
    pi.pno
    ,pi.recent_pno
    ,ss.name 揽收网点
    ,pi.ticket_pickup_staff_info_id 揽收快递员
    ,ss2.name 目的地网点
    ,oi.weight 订单重量
    ,pi.src_name 寄件人姓名
    ,pi.src_detail_address 寄件人地址
    ,pi.src_phone 寄件人
    ,pi.dst_name 收件人姓名
    ,pi.dst_phone 收件人电话
    ,pi.dst_detail_address 收件人地址
    ,p1.pri_num 打印面单次数
from ph_staging.parcel_info pi
left join ph_staging.order_info oi on oi.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
left join p p1 on p1.pno = pi.pno
where
    pi.pno in ('P02151SMA10AC','P02151SM9ZRAC','P02151SM9PSAG','P02081SM9JVAC','P02151SM9CZAC','P02081SM9C3AC','P02151SM9BSAC','P02081SM9BRAC','P02151SM9AYAC','P02151SM9AVAC','P02151SM9A9AC','P02151SM998AC','P02151SM96VAC','P02151SM926AC','P02081SM8Z1AC','P02151SM8TAAC','P02081SM8MPAC');
;-- -. . -..- - / . -. - .-. -.--
with p as
(
    select
        pr.pno
        ,count(pr.id) pri_num
    from ph_staging.parcel_route pr
    where
        pr.pno in ('P02151SMA10AC','P02151SM9ZRAC','P02151SM9PSAG','P02081SM9JVAC','P02151SM9CZAC','P02081SM9C3AC','P02151SM9BSAC','P02081SM9BRAC','P02151SM9AYAC','P02151SM9AVAC','P02151SM9A9AC','P02151SM998AC','P02151SM96VAC','P02151SM926AC','P02081SM8Z1AC','P02151SM8TAAC','P02081SM8MPAC')
        and pr.route_action = 'PRINTING'
    group by 1
)

select
    pi.pno
    ,pi.recent_pno
    ,convert_tz(pi.created_at, '+00:00', '+08:00') 揽收时间
    ,ss.name 揽收网点
    ,pi.ticket_pickup_staff_info_id 揽收快递员
    ,ss2.name 目的地网点
    ,oi.weight 订单重量
    ,pi.src_name 寄件人姓名
    ,pi.src_detail_address 寄件人地址
    ,pi.src_phone 寄件人
    ,pi.dst_name 收件人姓名
    ,pi.dst_phone 收件人电话
    ,pi.dst_detail_address 收件人地址
    ,p1.pri_num 打印面单次数
from ph_staging.parcel_info pi
left join ph_staging.order_info oi on oi.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_pickup_store_id
left join ph_staging.sys_store ss2 on ss2.id = pi.dst_store_id
left join p p1 on p1.pno = pi.pno
where
    pi.pno in ('P02151SMA10AC','P02151SM9ZRAC','P02151SM9PSAG','P02081SM9JVAC','P02151SM9CZAC','P02081SM9C3AC','P02151SM9BSAC','P02081SM9BRAC','P02151SM9AYAC','P02151SM9AVAC','P02151SM9A9AC','P02151SM998AC','P02151SM96VAC','P02151SM926AC','P02081SM8Z1AC','P02151SM8TAAC','P02081SM8MPAC');
;-- -. . -..- - / . -. - .-. -.--
select
    oi.ka_warehouse_id
from ph_staging.order_info oi
where
    oi.pno in ('P02151SMA10AC','P02151SM9ZRAC','P02151SM9PSAG','P02081SM9JVAC','P02151SM9CZAC','P02081SM9C3AC','P02151SM9BSAC','P02081SM9BRAC','P02151SM9AYAC','P02151SM9AVAC','P02151SM9A9AC','P02151SM998AC','P02151SM96VAC','P02151SM926AC','P02081SM8Z1AC','P02151SM8TAAC','P02081SM8MPAC');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.ka_warehouse_id
from ph_staging.parcel_info pi
where
    pi.pno in ('P02151SMA10AC','P02151SM9ZRAC','P02151SM9PSAG','P02081SM9JVAC','P02151SM9CZAC','P02081SM9C3AC','P02151SM9BSAC','P02081SM9BRAC','P02151SM9AYAC','P02151SM9AVAC','P02151SM9A9AC','P02151SM998AC','P02151SM96VAC','P02151SM926AC','P02081SM8Z1AC','P02151SM8TAAC','P02081SM8MPAC');
;-- -. . -..- - / . -. - .-. -.--
select
    pi.src_phone
from ph_staging.parcel_info pi
where
    pi.pno in ('P02151SMA10AC','P02151SM9ZRAC','P02151SM9PSAG','P02081SM9JVAC','P02151SM9CZAC','P02081SM9C3AC','P02151SM9BSAC','P02081SM9BRAC','P02151SM9AYAC','P02151SM9AVAC','P02151SM9A9AC','P02151SM998AC','P02151SM96VAC','P02151SM926AC','P02081SM8Z1AC','P02151SM8TAAC','P02081SM8MPAC')
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        hsi.staff_info_id
        ,hsi.name staff_name
        ,hsi.formal
        ,hjt.job_name
        ,hsi.state
        ,hsi.hire_date
        ,hsi.wait_leave_state
        ,ss.name
        ,smp.name mp_name
        ,smr.name mr_name
    from ph_bi.hr_staff_info hsi
    left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
    left join ph_staging.sys_manage_piece smp on smp.id = ss.manage_piece
    left join ph_staging.sys_manage_region smr on smr.id= ss.manage_region
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_backyard.staff_todo_list stl on hsi.staff_info_id = stl.staff_info_id
    where
        stl.staff_info_id is null
        and hsi.job_title in (13,110,1000,37) -- 仓管&快递员
        and hsi.state in (1,3)
)
select
    t1.staff_info_id 员工ID
    ,t1.staff_name 员工姓名
    ,date(t1.hire_date) 入职时间
    ,t1.job_name 职位
    ,case t1.formal
        when 1 then '正式'
        when 0 then '外协'
        when 2 then '加盟商'
        when 3 then '其他'
    end 员工属性
    ,case
        when  t1.`state`=1 and t1.`wait_leave_state` =0 then '在职'
        when  t1.`state`=1 and t1.`wait_leave_state` =1 then '待离职'
        when t1.`state` =2 then '离职'
        when t1.`state` =3 then '停职'
    end 员工状态
    ,t1.name 所属网点
    ,t1.mp_name 所属片区d
    ,t1.mr_name 所属大区
    ,sa5.version 员工kit最新版本
    ,sa6.version 员工backyard最新版本


    ,swa.end_at 0711下班打卡时间
    ,swa.end_clientid 0711下班打卡设备id
    ,if((ad.`shift_start`<>'' or ad.`shift_end`<>''),1,0) 0711是否排班
    ,if((ad.`attendance_started_at` is not null or ad.`attendance_end_at` is not null),1,0) 0711是否出勤
    ,if(length(ad.leave_type ) > 0 , 1, 0) 0711是否请假
    ,case sa.equipment_type
        when 1 then 'kit'
        when 3 then 'backyard'
    end 0711下班打卡设备

    ,swa2.end_at 0712下班打卡时间
    ,swa2.end_clientid 0712下班打卡设备id
    ,if((ad2.`shift_start`<>'' or ad2.`shift_end`<>''),1,0) 0712是否排班
    ,if((ad2.`attendance_started_at` is not null or ad2.`attendance_end_at` is not null),1,0) 0712是否出勤
    ,if(length(ad2.leave_type ) > 0 , 1, 0)0712是否请假
    ,case sa2.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0712下班打卡设备

    ,swa3.end_at 0713下班打卡时间
    ,swa3.end_clientid 0713下班打卡设备id
    ,if((ad3.`shift_start`<>'' or ad3.`shift_end`<>''),1,0) 0713是否排班
    ,if((ad3.`attendance_started_at` is not null or ad3.`attendance_end_at` is not null),1,0) 0713是否出勤
    ,if(length(ad3.leave_type ) > 0 , 1, 0) 0713是否请假
    ,case sa3.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0713下班打卡设备

    ,swa4.end_at 0714下班打卡时间
    ,swa4.end_clientid 0714下班打卡设备id
    ,if((ad4.`shift_start`<>'' or ad4.`shift_end`<>''),1,0) 0714是否排班
    ,if((ad4.`attendance_started_at` is not null or ad4.`attendance_end_at` is not null),1,0) 0714是否出勤
    ,if(length(ad4.leave_type ) > 0 , 1, 0) 0714是否请假
    ,case sa4.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0714下班打卡设备

    ,swa7.end_at 0715下班打卡时间
    ,swa7.end_clientid 0715下班打卡设备id
    ,if((ad7.`shift_start`<>'' or ad7.`shift_end`<>''),1,0) 0715是否排班
    ,if((ad7.`attendance_started_at` is not null or ad7.`attendance_end_at` is not null),1,0) 0715是否出勤
    ,if(length(ad7.leave_type ) > 0 , 1, 0) 0715是否请假
    ,case sa7.equipment_type
        when 1 then 'kit'
        when 2 then 'kit'
        when 3 then 'backyard'
        when 4 then 'fleet'
        when 5 then 'ms'
        when 6 then 'fbi'
        when 7 then 'fh'
        when 8 then 'fls'
        when 9 then 'ces'
    end 0715下班打卡设备
from t t1
left join ph_backyard.staff_work_attendance swa on swa.staff_info_id = t1.staff_info_id and swa.attendance_date = '2023-07-11'
left join ph_staging.staff_account sa on sa.clientid = swa.end_clientid and swa.staff_info_id = sa.staff_info_id
left join ph_bi.attendance_data_v2 ad on ad.staff_info_id = t1.staff_info_id and ad.stat_date = swa.attendance_date

left join ph_backyard.staff_work_attendance swa2 on swa2.staff_info_id = t1.staff_info_id and swa2.attendance_date = '2023-07-12'
left join ph_staging.staff_account sa2 on sa2.clientid = swa2.end_clientid and swa2.staff_info_id = sa2.staff_info_id
left join ph_bi.attendance_data_v2 ad2 on ad2.staff_info_id = t1.staff_info_id and ad2.stat_date = swa2.attendance_date

left join ph_backyard.staff_work_attendance swa3 on swa3.staff_info_id = t1.staff_info_id and swa3.attendance_date = '2023-07-13'
left join ph_staging.staff_account sa3 on sa3.clientid = swa3.end_clientid and swa3.staff_info_id = sa3.staff_info_id
left join ph_bi.attendance_data_v2 ad3 on ad3.staff_info_id = t1.staff_info_id and ad3.stat_date = swa3.attendance_date

left join ph_backyard.staff_work_attendance swa4 on swa4.staff_info_id = t1.staff_info_id and swa4.attendance_date = '2023-07-14'
left join ph_staging.staff_account sa4 on sa4.clientid = swa4.end_clientid and swa4.staff_info_id = sa4.staff_info_id
left join ph_bi.attendance_data_v2 ad4 on ad4.staff_info_id = t1.staff_info_id and ad4.stat_date = swa4.attendance_date

left join ph_backyard.staff_work_attendance swa7 on swa7.staff_info_id = t1.staff_info_id and swa7.attendance_date = '2023-07-15'
left join ph_staging.staff_account sa7 on sa7.clientid = swa7.end_clientid and swa7.staff_info_id = sa7.staff_info_id
left join ph_bi.attendance_data_v2 ad7 on ad7.staff_info_id = t1.staff_info_id and ad7.stat_date = swa7.attendance_date

left join ph_staging.staff_account sa5 on sa5.staff_info_id = t1.staff_info_id and sa5.equipment_type = 1-- kit
left join ph_staging.staff_account sa6 on sa6.staff_info_id = t1.staff_info_id and sa6.equipment_type = 3;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        dp.store_name
        ,ds.store_delivery_frequency
        ,dp.piece_name
        ,dp.region_name
        ,ds.pno
        ,ds.arrival_scan_route_at
        ,case
            when ds.store_delivery_frequency = 1 then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and  ds.arrival_scan_route_at < '2023-07-14 10:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-14 10:00:00' then 2
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at < '2023-07-14 09:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-14 09:00:00' then 2
        end delivery_fre
    from ph_bi.dc_should_delivery_today ds
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ds.store_id and dp.stat_date =date_sub(curdate(), interval 1 day)
    where
        ds.stat_date = '2023-07-14'
)
,sort as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,convert_tz(pr.routed_at, '+00:00', '+08:00') rou_time
                ,row_number() over (partition by pr.pno order by pr.routed_at) rk
            from ph_staging.parcel_route pr
            join t t1 on t1.pno = pr.pno
            where
                pr.route_action = 'SORTING_SCAN'
                and pr.routed_at >= '2023-07-13 16:00:00'
                and pr.routed_at < '2023-07-14 16:00:00'
        ) a
    where
        a.rk = 1
)

select
    t1.store_name 网点
    ,case t1.store_delivery_frequency
        when 1 then '一派'
        when 2 then '二派'
    end '一派/二派'
    ,t1.piece_name 片区
    ,t1.region_name 大区
    ,count(if(t1.delivery_fre = 1, t1.pno, null)) 一派应派件数
    ,count(if(t1.delivery_fre = 1 and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派分拣扫描率
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 08:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0800前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 08:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0830前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 09:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0900前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 09:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0930前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 10:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 1000前占比
    ,count(if(t1.delivery_fre = 2, t1.pno, null)) 二派应派件数
    ,count(if(t1.delivery_fre = 2 and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派分拣扫描率
from t t1
left join sort s2 on t1.pno = s2.pno
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        dp.store_name
        ,dp.store_id
        ,ds.store_delivery_frequency
        ,dp.piece_name
        ,dp.region_name
        ,ds.pno
        ,ds.arrival_scan_route_at
        ,case
            when ds.store_delivery_frequency = 1 then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and  ds.arrival_scan_route_at < '2023-07-14 10:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-14 10:00:00' then 2
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at < '2023-07-14 09:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-14 09:00:00' then 2
        end delivery_fre
    from ph_bi.dc_should_delivery_today ds
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ds.store_id and dp.stat_date =date_sub(curdate(), interval 1 day)
    where
        ds.stat_date = '2023-07-14'
)
,sort as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,convert_tz(pr.routed_at, '+00:00', '+08:00') rou_time
                ,row_number() over (partition by pr.pno order by pr.routed_at) rk
            from ph_staging.parcel_route pr
            join t t1 on t1.pno = pr.pno
            where
                pr.route_action = 'SORTING_SCAN'
                and pr.routed_at >= '2023-07-13 16:00:00'
                and pr.routed_at < '2023-07-14 16:00:00'
        ) a
    where
        a.rk = 1
)

select
    t1.store_name 网点
    ,t1.store_id
    ,case t1.store_delivery_frequency
        when 1 then '一派'
        when 2 then '二派'
    end '一派/二派'
    ,t1.piece_name 片区
    ,t1.region_name 大区
    ,count(if(t1.delivery_fre = 1, t1.pno, null)) 一派应派件数
    ,count(if(t1.delivery_fre = 1 and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派分拣扫描率
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 08:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0800前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 08:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0830前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 09:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0900前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 09:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0930前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 10:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 1000前占比
    ,count(if(t1.delivery_fre = 2, t1.pno, null)) 二派应派件数
    ,count(if(t1.delivery_fre = 2 and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派分拣扫描率
from t t1
left join sort s2 on t1.pno = s2.pno
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        dp.store_name
        ,dp.store_id
        ,ds.store_delivery_frequency
        ,dp.piece_name
        ,dp.region_name
        ,ds.pno
        ,ds.arrival_scan_route_at
        ,case
            when ds.store_delivery_frequency = 1 then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and  ds.arrival_scan_route_at < '2023-07-14 10:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-14 10:00:00' then 2
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at < '2023-07-14 09:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-14 09:00:00' then 2
        end delivery_fre
    from ph_bi.dc_should_delivery_today ds
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ds.store_id and dp.stat_date =date_sub(curdate(), interval 1 day)
    where
        ds.stat_date = '2023-07-14'
)
,sort as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,convert_tz(pr.routed_at, '+00:00', '+08:00') rou_time
                ,row_number() over (partition by pr.pno order by pr.routed_at) rk
            from ph_staging.parcel_route pr
            join t t1 on t1.pno = pr.pno
            where
                pr.route_action = 'SORTING_SCAN'
                and pr.routed_at >= '2023-07-13 16:00:00'
                and pr.routed_at < '2023-07-14 16:00:00'
        ) a
    where
        a.rk = 1
)

select
    t1.store_name 网点
    ,t1.store_id
    ,case t1.store_delivery_frequency
        when 1 then '一派'
        when 2 then '二派'
    end '一派/二派'
    ,t1.piece_name 片区
    ,t1.region_name 大区
    ,count(t1.pno) 应派总数
    ,f.delivery_count/count(t1.pno) '当日分拣扫描占比(时效内)'
    ,count(if(t1.delivery_fre = 1, t1.pno, null)) 一派应派件数
    ,count(if(t1.delivery_fre = 1 and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派分拣扫描率
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 08:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0800前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 08:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0830前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 09:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0900前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 09:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0930前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 10:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 1000前占比
    ,count(if(t1.delivery_fre = 2, t1.pno, null)) 二派应派件数
    ,count(if(t1.delivery_fre = 2 and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派分拣扫描率
from t t1
left join sort s2 on t1.pno = s2.pno
left join ph_bi.finance_keeper_new_achievements f on f.store_id = t1.store_id and f.stat_date = '2023-07-14'
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        dp.store_name
        ,dp.store_id
        ,ds.store_delivery_frequency
        ,dp.piece_name
        ,dp.region_name
        ,ds.pno
        ,ds.arrival_scan_route_at
        ,case
            when ds.store_delivery_frequency = 1 then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and  ds.arrival_scan_route_at < '2023-07-14 10:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-14 10:00:00' then 2
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at < '2023-07-14 09:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-14 09:00:00' then 2
        end delivery_fre
    from ph_bi.dc_should_delivery_today ds
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ds.store_id and dp.stat_date =date_sub(curdate(), interval 1 day)
    where
        ds.stat_date = '2023-07-14'
)
,sort as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,convert_tz(pr.routed_at, '+00:00', '+08:00') rou_time
                ,row_number() over (partition by pr.pno order by pr.routed_at) rk
            from ph_staging.parcel_route pr
            join t t1 on t1.pno = pr.pno
            where
                pr.route_action = 'SORTING_SCAN'
                and pr.routed_at >= '2023-07-13 16:00:00'
                and pr.routed_at < '2023-07-14 16:00:00'
        ) a
    where
        a.rk = 1
)

select
    t1.store_name 网点
    ,t1.store_id
    ,case t1.store_delivery_frequency
        when 1 then '一派'
        when 2 then '二派'
    end '一派/二派'
    ,t1.piece_name 片区
    ,t1.region_name 大区
    ,count(t1.pno) 应派总数
    ,f.delivery_count 仓管派件量
    ,f.delivery_count/count(t1.pno) '当日分拣扫描占比(时效内)'
    ,count(if(t1.delivery_fre = 1, t1.pno, null)) 一派应派件数
    ,count(if(t1.delivery_fre = 1 and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派分拣扫描率
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 08:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0800前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 08:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0830前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 09:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0900前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 09:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0930前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 10:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 1000前占比
    ,count(if(t1.delivery_fre = 2, t1.pno, null)) 二派应派件数
    ,count(if(t1.delivery_fre = 2 and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派分拣扫描率
from t t1
left join sort s2 on t1.pno = s2.pno
left join ph_bi.finance_keeper_new_achievements f on f.store_id = t1.store_id and f.stat_date = '2023-07-14'
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,hsi3.name submitter_name
    ,hjt2.job_name submitter_job
    ,ra.report_id
    ,concat(tp.cn, tp.eng) reason
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') picture
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join ph_bi.hr_staff_info hsi3 on hsi3.staff_info_id = ra.submitter_id
left join ph_bi.hr_job_title hjt2 on hjt2.id = hsi3.job_title
left join tmpale.tmp_ph_report_reason tp on tp.key = ra.reason
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id and sa.oss_bucket_type = 'REPORT_AUDIT_IMG'
where
    ra.created_at >= '2023-07-10'
    and ra.status = 2
#     and ra.final_approval_time >= date_sub(curdate(), interval 11 hour)
    and ra.final_approval_time >= '2023-07-14 14:00:00'
    and ra.final_approval_time < '2023-07-16 14:00:00'
group by 1
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,a1.id 举报记录ID
    ,a1.submitter_id 举报人工号
    ,a1.submitter_name 举报人姓名
    ,a1.submitter_job 举报人职位
    ,hsi.name 被举报人姓名
    ,date(hsi.hire_date) 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.reason 举报原因
    ,a1.remark 事情描述
    ,a1.picture 图片
    ,hsi.mobile 手机号

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,case
        when smr.name in ('Area3', 'Area6') then '彭万松'
        when smr.name in ('Area4', 'Area9') then '韩钥'
        when smr.name in ('Area7', 'Area8','Area10', 'Area11','FHome') then '张可新'
        when smr.name in ('Area1', 'Area2','Area5', 'Area12') then '李俊'
    end 负责人
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        dp.store_name
        ,dp.store_id
        ,ds.store_delivery_frequency
        ,dp.piece_name
        ,dp.region_name
        ,ds.pno
        ,ds.arrival_scan_route_at
        ,ds.vehicle_time
        ,case
            when ds.store_delivery_frequency = 1 then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and  ds.arrival_scan_route_at < '2023-07-15 10:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-15 10:00:00' then 2
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at < '2023-07-15 09:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-15 09:00:00' then 2
        end delivery_fre
    from ph_bi.dc_should_delivery_today ds
    left join dwm.dim_th_sys_store_rd dp on dp.store_id = ds.store_id and dp.stat_date =date_sub(curdate(), interval 1 day)
    where
        ds.stat_date = '2023-07-15'
)
,sort as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,convert_tz(pr.routed_at, '+00:00', '+08:00') rou_time
                ,row_number() over (partition by pr.pno order by pr.routed_at) rk
            from ph_staging.parcel_route pr
            join t t1 on t1.pno = pr.pno
            where
                pr.route_action = 'SORTING_SCAN'
                and pr.routed_at >= '2023-07-14 16:00:00'
                and pr.routed_at < '2023-07-15 16:00:00'
        ) a
    where
        a.rk = 1
)

select
    t1.store_name 网点
    ,t1.store_id 网点ID
    ,case t1.store_delivery_frequency
        when 1 then '一派'
        when 2 then '二派'
    end '一派/二派'
    ,t1.piece_name 片区
    ,t1.region_name 大区
    ,count(t1.pno) 应派总量
    ,count(if(f.pno is not null , t1.pno, null)) 总有效分拣扫描数
    ,count(if(s2.rou_time is not null , t1.pno, null))/count(t1.pno) 总分拣扫描率
    ,count(if(f.pno is not null , t1.pno, null))/count(t1.pno) 总有效分拣扫描率
    ,count(if(t1.delivery_fre = 1, t1.pno, null)) 一派应派件数
    ,ve1.max_veh_time 一派最晚到港时间
    ,count(if(t1.delivery_fre = 1 and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派分拣扫描率
    ,count(if(t1.delivery_fre = 1 and f.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派有效分拣扫描率
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 08:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0800前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 08:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0830前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 09:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0900前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 09:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0930前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 10:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 1000前占比
    ,count(if(t1.delivery_fre = 2, t1.pno, null)) 二派应派件数
    ,ve2.max_veh_time 二派最晚到港时间
    ,count(if(t1.delivery_fre = 2 and f.pno is not null, t1.pno, null )) 二派有效分拣数
    ,count(if(t1.delivery_fre = 2 and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派分拣扫描率
    ,count(if(t1.delivery_fre = 2 and f.pno is not null , t1.pno, null))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派有效分拣扫描率
from t t1
left join sort s2 on t1.pno = s2.pno
left join ph_bi.finance_keeper_month_parcel_v3 f on f.pno = t1.pno and f.store_id = t1.store_id and f.stat_date = '2023-07-15' and f.type = 2
left join
    (
        select
            t1.store_id
            ,max(t1.vehicle_time) max_veh_time
        from t t1
        where
            t1.delivery_fre = 1
        group by 1
    ) ve1 on ve1.store_id = t1.store_id
left join
    (
        select
            t1.store_id
            ,max(t1.vehicle_time) max_veh_time
        from t t1
        where
            t1.delivery_fre = 2
        group by 1
    ) ve2 on ve2.store_id = t1.store_id
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        dp.store_name
        ,dp.store_id
        ,ds.store_delivery_frequency
        ,dp.piece_name
        ,dp.region_name
        ,ds.pno
        ,ds.arrival_scan_route_at
        ,ds.vehicle_time
        ,case
            when ds.store_delivery_frequency = 1 then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and  ds.arrival_scan_route_at < '2023-07-15 10:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-15 10:00:00' then 2
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at < '2023-07-15 09:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-15 09:00:00' then 2
        end delivery_fre
    from ph_bi.dc_should_delivery_today ds
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ds.store_id and dp.stat_date =date_sub(curdate(), interval 1 day)
    where
        ds.stat_date = '2023-07-15'
)
,sort as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,convert_tz(pr.routed_at, '+00:00', '+08:00') rou_time
                ,row_number() over (partition by pr.pno order by pr.routed_at) rk
            from ph_staging.parcel_route pr
            join t t1 on t1.pno = pr.pno
            where
                pr.route_action = 'SORTING_SCAN'
                and pr.routed_at >= '2023-07-14 16:00:00'
                and pr.routed_at < '2023-07-15 16:00:00'
        ) a
    where
        a.rk = 1
)

select
    t1.store_name 网点
    ,t1.store_id 网点ID
    ,case t1.store_delivery_frequency
        when 1 then '一派'
        when 2 then '二派'
    end '一派/二派'
    ,t1.piece_name 片区
    ,t1.region_name 大区
    ,count(t1.pno) 应派总量
    ,count(if(f.pno is not null , t1.pno, null)) 总有效分拣扫描数
    ,count(if(s2.rou_time is not null , t1.pno, null))/count(t1.pno) 总分拣扫描率
    ,count(if(f.pno is not null , t1.pno, null))/count(t1.pno) 总有效分拣扫描率
    ,count(if(t1.delivery_fre = 1, t1.pno, null)) 一派应派件数
    ,ve1.max_veh_time 一派最晚到港时间
    ,count(if(t1.delivery_fre = 1 and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派分拣扫描率
    ,count(if(t1.delivery_fre = 1 and f.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派有效分拣扫描率
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 08:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0800前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 08:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0830前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 09:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0900前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 09:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0930前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-14 10:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 1000前占比
    ,count(if(t1.delivery_fre = 2, t1.pno, null)) 二派应派件数
    ,ve2.max_veh_time 二派最晚到港时间
    ,count(if(t1.delivery_fre = 2 and f.pno is not null, t1.pno, null )) 二派有效分拣数
    ,count(if(t1.delivery_fre = 2 and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派分拣扫描率
    ,count(if(t1.delivery_fre = 2 and f.pno is not null , t1.pno, null))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派有效分拣扫描率
from t t1
left join sort s2 on t1.pno = s2.pno
left join ph_bi.finance_keeper_month_parcel_v3 f on f.pno = t1.pno and f.store_id = t1.store_id and f.stat_date = '2023-07-15' and f.type = 2
left join
    (
        select
            t1.store_id
            ,max(t1.vehicle_time) max_veh_time
        from t t1
        where
            t1.delivery_fre = 1
        group by 1
    ) ve1 on ve1.store_id = t1.store_id
left join
    (
        select
            t1.store_id
            ,max(t1.vehicle_time) max_veh_time
        from t t1
        where
            t1.delivery_fre = 2
        group by 1
    ) ve2 on ve2.store_id = t1.store_id
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        dp.store_name
        ,dp.store_id
        ,ds.store_delivery_frequency
        ,dp.piece_name
        ,dp.region_name
        ,ds.pno
        ,ds.arrival_scan_route_at
        ,ds.vehicle_time
        ,case
            when ds.store_delivery_frequency = 1 then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and  ds.arrival_scan_route_at < '2023-07-15 10:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-15 10:00:00' then 2
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at < '2023-07-15 09:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-15 09:00:00' then 2
        end delivery_fre
    from ph_bi.dc_should_delivery_today ds
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ds.store_id and dp.stat_date =date_sub(curdate(), interval 1 day)
    where
        ds.stat_date = '2023-07-15'
)
,sort as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,convert_tz(pr.routed_at, '+00:00', '+08:00') rou_time
                ,row_number() over (partition by pr.pno order by pr.routed_at) rk
            from ph_staging.parcel_route pr
            join t t1 on t1.pno = pr.pno
            where
                pr.route_action = 'SORTING_SCAN'
                and pr.routed_at >= '2023-07-14 16:00:00'
                and pr.routed_at < '2023-07-15 16:00:00'
        ) a
    where
        a.rk = 1
)

select
    t1.store_name 网点
    ,t1.store_id 网点ID
    ,case t1.store_delivery_frequency
        when 1 then '一派'
        when 2 then '二派'
    end '一派/二派'
    ,t1.piece_name 片区
    ,t1.region_name 大区
    ,count(t1.pno) 应派总量
    ,count(if(f.pno is not null and s2.pno is not null, t1.pno, null)) 总有效分拣扫描数
    ,count(if(s2.rou_time is not null , t1.pno, null))/count(t1.pno) 总分拣扫描率
    ,count(if(f.pno is not null and s2.pno is not null, t1.pno, null))/count(t1.pno) 总有效分拣扫描率
    ,count(if(t1.delivery_fre = 1, t1.pno, null)) 一派应派件数
    ,ve1.max_veh_time 一派最晚到港时间
    ,count(if(t1.delivery_fre = 1 and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派分拣扫描率
    ,count(if(t1.delivery_fre = 1 and f.pno is not null and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派有效分拣扫描率
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 08:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0800前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 08:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0830前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 09:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0900前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 09:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0930前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 10:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 1000前占比
    ,count(if(t1.delivery_fre = 2, t1.pno, null)) 二派应派件数
    ,ve2.max_veh_time 二派最晚到港时间
    ,count(if(t1.delivery_fre = 2 and f.pno is not null and s2.pno is not null, t1.pno, null )) 二派有效分拣数
    ,count(if(t1.delivery_fre = 2 and s2.pno is not null , t1.pno, null ))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派分拣扫描率
    ,count(if(t1.delivery_fre = 2 and f.pno is not null and s2.pno is not null, t1.pno, null))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派有效分拣扫描率
from t t1
left join sort s2 on t1.pno = s2.pno
left join ph_bi.finance_keeper_month_parcel_v3 f on f.pno = t1.pno and f.store_id = t1.store_id and f.stat_date = '2023-07-15' and f.type = 2
left join
    (
        select
            t1.store_id
            ,max(t1.vehicle_time) max_veh_time
        from t t1
        where
            t1.delivery_fre = 1
        group by 1
    ) ve1 on ve1.store_id = t1.store_id
left join
    (
        select
            t1.store_id
            ,max(t1.vehicle_time) max_veh_time
        from t t1
        where
            t1.delivery_fre = 2
        group by 1
    ) ve2 on ve2.store_id = t1.store_id
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,de.dst_store_id
        ,de.dst_store
        ,de.dst_region
        ,de.dst_piece
        ,pi.state
        ,pi.dst_phone
        ,pi.dst_home_phone
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_info pi on de.pno = pi.pno
    left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'PENDING_RETURN'
    where
        datediff(now(), de.dst_routed_at) <= 7
        and pi.state not in (5,7,8,9)
        and bc.client_id is null
        and pr.pno is not null
    group by 1
)
select
    t1.pno
    ,t1.dst_store 目的地网点
    ,t1.dst_store_id 目的网点ID
    ,t1.dst_piece 目的地片区
    ,t1.dst_region 目的地大区
    ,case t1.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as `包裹状态`
    ,t1.dst_phone 收件人电话
    ,t1.dst_home_phone 收件人家庭电话
    ,count(distinct ppd.mark_date) 尝试天数
from t t1
left join
    (
        select
            td.pno
            ,date(convert_tz(tdm.created_at, '+00:00', '+08:00')) mark_date
        from ph_staging.ticket_delivery td
        join t t1 on t1.pno = td.pno
        left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
        group by 1,2
    ) mark on mark.pno = t1.pno
left join
    (
        select
            ppd.pno
            ,date(convert_tz(ppd.created_at, '+00:00', '+08:00')) mark_date
        from ph_staging.parcel_problem_detail ppd
        join t t1 on t1.pno = ppd.pno
        where
            ppd.diff_marker_category not in (7,22,5,20,6,21,15,71)
        group by 1,2
    ) ppd on ppd.pno = mark.pno and mark.mark_date = ppd.mark_date
where
    ppd.mark_date is not null
group by 1
having count(distinct ppd.mark_date) >= 3;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,de.dst_store_id
        ,de.dst_store
        ,de.dst_region
        ,de.dst_piece
        ,pi.state
        ,pi.dst_phone
        ,pi.dst_home_phone
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_info pi on de.pno = pi.pno
    left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'PENDING_RETURN'
    where
        datediff(now(), de.dst_routed_at) <= 7
        and pi.state not in (5,7,8,9)
        and bc.client_id is null
        and pr.pno is null
    group by 1
)
select
    t1.pno
    ,t1.dst_store 目的地网点
    ,t1.dst_store_id 目的网点ID
    ,t1.dst_piece 目的地片区
    ,t1.dst_region 目的地大区
    ,case t1.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as `包裹状态`
    ,t1.dst_phone 收件人电话
    ,t1.dst_home_phone 收件人家庭电话
    ,count(distinct ppd.mark_date) 尝试天数
from t t1
left join
    (
        select
            td.pno
            ,date(convert_tz(tdm.created_at, '+00:00', '+08:00')) mark_date
        from ph_staging.ticket_delivery td
        join t t1 on t1.pno = td.pno
        left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
        group by 1,2
    ) mark on mark.pno = t1.pno
left join
    (
        select
            ppd.pno
            ,date(convert_tz(ppd.created_at, '+00:00', '+08:00')) mark_date
        from ph_staging.parcel_problem_detail ppd
        join t t1 on t1.pno = ppd.pno
        where
            ppd.diff_marker_category not in (7,22,5,20,6,21,15,71)
        group by 1,2
    ) ppd on ppd.pno = mark.pno and mark.mark_date = ppd.mark_date
where
    ppd.mark_date is not null
group by 1
having count(distinct ppd.mark_date) >= 3;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        dp.store_name
        ,dp.store_id
        ,ds.store_delivery_frequency
        ,dp.piece_name
        ,dp.region_name
        ,ds.pno
        ,ds.arrival_scan_route_at
        ,ds.vehicle_time
        ,case
            when ds.store_delivery_frequency = 1 then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and  ds.arrival_scan_route_at < '2023-07-15 10:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-15 10:00:00' then 2
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at < '2023-07-15 09:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-15 09:00:00' then 2
        end delivery_fre
    from ph_bi.dc_should_delivery_today ds
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ds.store_id and dp.stat_date =date_sub(curdate(), interval 1 day)
    where
        ds.stat_date = '2023-07-15'
        and if(ds.original_store_id is null , 1 = 1, ds.original_store_id != ds.store_id)
)
,sort as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,convert_tz(pr.routed_at, '+00:00', '+08:00') rou_time
                ,row_number() over (partition by pr.pno order by pr.routed_at) rk
            from ph_staging.parcel_route pr
            join t t1 on t1.pno = pr.pno
            where
                pr.route_action = 'SORTING_SCAN'
                and pr.routed_at >= '2023-07-14 16:00:00'
                and pr.routed_at < '2023-07-15 16:00:00'
        ) a
    where
        a.rk = 1
)

select
    t1.store_name 网点
    ,t1.store_id 网点ID
    ,case t1.store_delivery_frequency
        when 1 then '一派'
        when 2 then '二派'
    end '一派/二派'
    ,t1.piece_name 片区
    ,t1.region_name 大区
    ,count(t1.pno) 应派总量
    ,count(if(f.pno is not null and s2.pno is not null, t1.pno, null)) 总有效分拣扫描数
    ,count(if(s2.rou_time is not null , t1.pno, null))/count(t1.pno) 总分拣扫描率
    ,count(if(f.pno is not null and s2.pno is not null, t1.pno, null))/count(t1.pno) 总有效分拣扫描率
    ,count(if(t1.delivery_fre = 1, t1.pno, null)) 一派应派件数
    ,ve1.max_veh_time 一派最晚到港时间
    ,count(if(t1.delivery_fre = 1 and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派分拣扫描率
    ,count(if(t1.delivery_fre = 1 and f.pno is not null and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派有效分拣扫描率
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 08:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0800前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 08:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0830前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 09:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0900前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 09:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0930前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 10:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 1000前占比
    ,count(if(t1.delivery_fre = 2, t1.pno, null)) 二派应派件数
    ,ve2.max_veh_time 二派最晚到港时间
    ,count(if(t1.delivery_fre = 2 and f.pno is not null and s2.pno is not null, t1.pno, null )) 二派有效分拣数
    ,count(if(t1.delivery_fre = 2 and s2.pno is not null , t1.pno, null ))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派分拣扫描率
    ,count(if(t1.delivery_fre = 2 and f.pno is not null and s2.pno is not null, t1.pno, null))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派有效分拣扫描率
from t t1
left join sort s2 on t1.pno = s2.pno
left join ph_bi.finance_keeper_month_parcel_v3 f on f.pno = t1.pno and f.store_id = t1.store_id and f.stat_date = '2023-07-15' and f.type = 2
left join
    (
        select
            t1.store_id
            ,max(t1.vehicle_time) max_veh_time
        from t t1
        where
            t1.delivery_fre = 1
        group by 1
    ) ve1 on ve1.store_id = t1.store_id
left join
    (
        select
            t1.store_id
            ,max(t1.vehicle_time) max_veh_time
        from t t1
        where
            t1.delivery_fre = 2
        group by 1
    ) ve2 on ve2.store_id = t1.store_id
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        dp.store_name
        ,dp.store_id
        ,ds.store_delivery_frequency
        ,dp.piece_name
        ,dp.region_name
        ,ds.pno
        ,ds.arrival_scan_route_at
        ,ds.vehicle_time
        ,case
            when ds.store_delivery_frequency = 1 then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and  ds.arrival_scan_route_at < '2023-07-15 10:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-15 10:00:00' then 2
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at < '2023-07-15 09:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-15 09:00:00' then 2
        end delivery_fre
    from ph_bi.dc_should_delivery_today ds
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ds.store_id and dp.stat_date =date_sub(curdate(), interval 1 day)
    where
        ds.stat_date = '2023-07-15'
        and if(ds.original_store_id is null , 1 = 1, ds.original_store_id != ds.store_id)
)
,sort as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,convert_tz(pr.routed_at, '+00:00', '+08:00') rou_time
                ,row_number() over (partition by pr.pno order by pr.routed_at) rk
            from ph_staging.parcel_route pr
            join t t1 on t1.pno = pr.pno and pr.store_id = t1.store_id
            where
                pr.route_action = 'SORTING_SCAN'
#                 and pr.routed_at >= '2023-07-14 16:00:00'
#                 and pr.routed_at < '2023-07-15 16:00:00'
        ) a
    where
        a.rk = 1
)

select
    t1.store_name 网点
    ,t1.store_id 网点ID
    ,case t1.store_delivery_frequency
        when 1 then '一派'
        when 2 then '二派'
    end '一派/二派'
    ,t1.piece_name 片区
    ,t1.region_name 大区
    ,count(t1.pno) 应派总量
    ,count(if(f.pno is not null and s2.pno is not null, t1.pno, null)) 总有效分拣扫描数
    ,count(if(s2.rou_time is not null , t1.pno, null))/count(t1.pno) 总分拣扫描率
    ,count(if(f.pno is not null and s2.pno is not null, t1.pno, null))/count(t1.pno) 总有效分拣扫描率
    ,count(if(t1.delivery_fre = 1, t1.pno, null)) 一派应派件数
    ,ve1.max_veh_time 一派最晚到港时间
    ,count(if(t1.delivery_fre = 1 and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派分拣扫描率
    ,count(if(t1.delivery_fre = 1 and f.pno is not null and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派有效分拣扫描率
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 08:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0800前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 08:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0830前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 09:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0900前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 09:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0930前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 10:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 1000前占比
    ,count(if(t1.delivery_fre = 2, t1.pno, null)) 二派应派件数
    ,ve2.max_veh_time 二派最晚到港时间
    ,count(if(t1.delivery_fre = 2 and f.pno is not null and s2.pno is not null, t1.pno, null )) 二派有效分拣数
    ,count(if(t1.delivery_fre = 2 and s2.pno is not null , t1.pno, null ))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派分拣扫描率
    ,count(if(t1.delivery_fre = 2 and f.pno is not null and s2.pno is not null, t1.pno, null))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派有效分拣扫描率
from t t1
left join sort s2 on t1.pno = s2.pno
left join ph_bi.finance_keeper_month_parcel_v3 f on f.pno = t1.pno and f.store_id = t1.store_id and f.stat_date = '2023-07-15' and f.type = 2
left join
    (
        select
            t1.store_id
            ,max(t1.vehicle_time) max_veh_time
        from t t1
        where
            t1.delivery_fre = 1
        group by 1
    ) ve1 on ve1.store_id = t1.store_id
left join
    (
        select
            t1.store_id
            ,max(t1.vehicle_time) max_veh_time
        from t t1
        where
            t1.delivery_fre = 2
        group by 1
    ) ve2 on ve2.store_id = t1.store_id
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        dp.store_name
        ,dp.store_id
        ,dp.store_category
        ,ds.store_delivery_frequency
        ,dp.piece_name
        ,dp.region_name
        ,ds.pno
        ,ds.arrival_scan_route_at
        ,ds.vehicle_time
        ,case
            when ds.store_delivery_frequency = 1 then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and  ds.arrival_scan_route_at < '2023-07-15 10:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-15 10:00:00' then 2
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at < '2023-07-15 09:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-15 09:00:00' then 2
        end delivery_fre
    from ph_bi.dc_should_delivery_today ds
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ds.store_id and dp.stat_date =date_sub(curdate(), interval 1 day)
    where
        ds.stat_date = '2023-07-15'
        and if(ds.original_store_id is null , 1 = 1, ds.original_store_id != ds.store_id)
)
,sort as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,convert_tz(pr.routed_at, '+00:00', '+08:00') rou_time
                ,row_number() over (partition by pr.pno order by pr.routed_at) rk
            from ph_staging.parcel_route pr
            join t t1 on t1.pno = pr.pno and pr.store_id = t1.store_id
            where
                pr.route_action = 'SORTING_SCAN'
#                 and pr.routed_at >= '2023-07-14 16:00:00'
#                 and pr.routed_at < '2023-07-15 16:00:00'
        ) a
    where
        a.rk = 1
)

select
    t1.store_name 网点
    ,t1.store_id 网点ID
    ,case t1.store_category
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
    ,case t1.store_delivery_frequency
        when 1 then '一派'
        when 2 then '二派'
    end '一派/二派'
    ,t1.piece_name 片区
    ,t1.region_name 大区
    ,count(t1.pno) 应派总量
    ,count(if(f.pno is not null and s2.pno is not null, t1.pno, null)) 总有效分拣扫描数
    ,count(if(s2.rou_time is not null , t1.pno, null))/count(t1.pno) 总分拣扫描率
    ,count(if(f.pno is not null and s2.pno is not null, t1.pno, null))/count(t1.pno) 总有效分拣扫描率
    ,count(if(t1.delivery_fre = 1, t1.pno, null)) 一派应派件数
    ,ve1.max_veh_time 一派最晚到港时间
    ,count(if(t1.delivery_fre = 1 and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派分拣扫描率
    ,count(if(t1.delivery_fre = 1 and f.pno is not null and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派有效分拣扫描率
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 08:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0800前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 08:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0830前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 09:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0900前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 09:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0930前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 10:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 1000前占比
    ,count(if(t1.delivery_fre = 2, t1.pno, null)) 二派应派件数
    ,ve2.max_veh_time 二派最晚到港时间
    ,count(if(t1.delivery_fre = 2 and f.pno is not null and s2.pno is not null, t1.pno, null )) 二派有效分拣数
    ,count(if(t1.delivery_fre = 2 and s2.pno is not null , t1.pno, null ))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派分拣扫描率
    ,count(if(t1.delivery_fre = 2 and f.pno is not null and s2.pno is not null, t1.pno, null))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派有效分拣扫描率
from t t1
left join sort s2 on t1.pno = s2.pno
left join ph_bi.finance_keeper_month_parcel_v3 f on f.pno = t1.pno and f.store_id = t1.store_id and f.stat_date = '2023-07-15' and f.type = 2
# left join
#     (
#         select
#             t1.store_id
#             ,max(t1.store_delivery_frequency) store_delivery_frequency
#         from t t1
#         group by 1
#     ) freq on freq.store_id = t1.store_id
left join
    (
        select
            t1.store_id
            ,max(t1.vehicle_time) max_veh_time
        from t t1
        where
            t1.delivery_fre = 1
        group by 1
    ) ve1 on ve1.store_id = t1.store_id
left join
    (
        select
            t1.store_id
            ,max(t1.vehicle_time) max_veh_time
        from t t1
        where
            t1.delivery_fre = 2
        group by 1
    ) ve2 on ve2.store_id = t1.store_id
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
        ,pi.dst_store_id
        ,pi.client_id
        ,pi.cod_enabled
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-06-21 16:00:00'
        and pi.state not in (5,7,8,9)
#         and pi.pno = 'P35231NPHV3BE'
)
select
    t1.pno
    ,if(t1.returned = 1, '退件', '正向件')  方向
    ,t1.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
#     ,case
#         when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
#         when t1.state = 6 and di.pno is null  then '闪速系统沟通处理中'
#         when t1.state != 6 and plt.pno is not null and plt2.pno is not null then '闪速系统沟通处理中'
#         when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
#         when de.last_store_id = t1.ticket_pickup_store_id and plt2.pno is null then '揽件未发出'
#         when t1.dst_store_id = 'PH19040F05' and plt2.pno is null then '弃件未到拍卖仓'
#         when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
#         else null
#     end 卡点原因
#     ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,pr.store_name 最后有效路由动作网点
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
    ,datediff(now(), de.dst_routed_at) 目的地网点停留时间
    ,de.dst_store 目的地网点
    ,de.src_store 揽收网点
    ,de.pickup_time 揽收时间
    ,de.pick_date 揽收日期
    ,if(hold.pno is not null, 'yes', 'no' ) 是否有holding标记
    ,if(pr3.pno is not null, 'yes', 'no') 是否有待退件标记
    ,td.try_num 尝试派送次数
from t t1
left join ph_staging.ka_profile kp on t1.client_id = kp.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
            and pr.organization_type = 1
        ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
left join
    (
        select
            pr2.pno
        from ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.route_action = 'REFUND_CONFIRM'
        group by 1
    ) hold on hold.pno = t1.pno
left join
    (
        select
            pr2.pno
        from  ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.route_action = 'PENDING_RETURN'
        group by 1
    ) pr3 on pr3.pno = t1.pno
left join
    (
        select
            td.pno
            ,count(distinct date(convert_tz(tdm.created_at, '+00:00', '+08:00'))) try_num
        from ph_staging.ticket_delivery td
        join t t1 on t1.pno = td.pno
        left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
        group by 1
    ) td on td.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    a.link_id
from
    (
        select
            sc.cfg_value
        from ph_staging.sys_configuration sc
        where
            sc.cfg_key = 'sorting.scan.enable.store.ids'

    ) a
lateral view explode(split(a.cfg_value, ',')) id as link_id;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,hsi3.name submitter_name
    ,hjt2.job_name submitter_job
    ,ra.report_id
    ,concat(tp.cn, tp.eng) reason
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') picture
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join ph_bi.hr_staff_info hsi3 on hsi3.staff_info_id = ra.submitter_id
left join ph_bi.hr_job_title hjt2 on hjt2.id = hsi3.job_title
left join tmpale.tmp_ph_report_reason tp on tp.key = ra.reason
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id and sa.oss_bucket_type = 'REPORT_AUDIT_IMG'
where
    ra.created_at >= '2023-07-10' -- 玺哥不看之前的数据
    and ra.status = 2
    and ra.final_approval_time >= date_sub(curdate(), interval 11 hour)
#     and ra.final_approval_time >= '2023-07-14 14:00:00'
#     and ra.final_approval_time < '2023-07-16 14:00:00'
group by 1
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,a1.id 举报记录ID
    ,a1.submitter_id 举报人工号
    ,a1.submitter_name 举报人姓名
    ,a1.submitter_job 举报人职位
    ,hsi.name 被举报人姓名
    ,date(hsi.hire_date) 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.reason 举报原因
    ,a1.remark 事情描述
    ,a1.picture 图片
    ,hsi.mobile 手机号

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,case
        when smr.name in ('Area3', 'Area6') then '彭万松'
        when smr.name in ('Area4', 'Area9') then '韩钥'
        when smr.name in ('Area7', 'Area8','Area10', 'Area11','FHome') then '张可新'
        when smr.name in ('Area1', 'Area2','Area5', 'Area12') then '李俊'
    end 负责人
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sy;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,hsi3.name submitter_name
    ,hjt2.job_name submitter_job
    ,ra.report_id
    ,concat(tp.cn, tp.eng) reason
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') picture
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join ph_bi.hr_staff_info hsi3 on hsi3.staff_info_id = ra.submitter_id
left join ph_bi.hr_job_title hjt2 on hjt2.id = hsi3.job_title
left join tmpale.tmp_ph_report_reason tp on tp.key = ra.reason
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id and sa.oss_bucket_type = 'REPORT_AUDIT_IMG'
where
    ra.created_at >= '2023-07-10' -- 玺哥不看之前的数据
    and ra.status = 2
    and ra.final_approval_time >= date_sub(curdate(), interval 11 hour)
#     and ra.final_approval_time >= '2023-07-14 14:00:00'
#     and ra.final_approval_time < '2023-07-16 14:00:00'
group by 1
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,a1.id 举报记录ID
    ,a1.submitter_id 举报人工号
    ,a1.submitter_name 举报人姓名
    ,a1.submitter_job 举报人职位
    ,hsi.name 被举报人姓名
    ,date(hsi.hire_date) 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.reason 举报原因
    ,a1.remark 事情描述
    ,a1.picture 图片
    ,hsi.mobile 手机号

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,case
        when smr.name in ('Area3', 'Area6') then '彭万松'
        when smr.name in ('Area4', 'Area9') then '韩钥'
        when smr.name in ('Area7', 'Area8','Area10', 'Area11','FHome') then '张可新'
        when smr.name in ('Area1', 'Area2','Area5', 'Area12') then '李俊'
    end 负责人
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,pr.routed_at
                ,pr.store_id
                ,pr.staff_info_id
                ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
            from ph_staging.parcel_route pr
            where
                pr.route_action = 'DELIVERY_MARKER'
                and pr.marker_category = 16
                and pr.routed_at >= '2023-07-16 16:00:00'
                and pr.routed_at < '2023-07-17 16:00:00'
        ) a
    where
        a.rk = 1
)
, a1 as
(
    select
            t.*
            ,pr2.extra_value
            ,pr2.id
            ,json_extract(pr2.extra_value, '$.callDuration') call_num -- 通话
            ,json_extract(pr2.extra_value, '$.diaboloDuration') diao_num -- 响铃
        from ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.routed_at >= '2023-07-16 16:00:00'
            and pr2.routed_at < '2023-07-17 16:00:00'
            and pr2.route_action = 'PHONE'
            and pr2.routed_at < t1.routed_at
)
select
    t1.pno
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,t1.staff_info_id 快递员
    ,hsi.hire_date 入职时间
    ,t1.尝试联系次数
    ,t2.diao_num 出现最多的响铃时长
    ,t1.最短响铃时长
    ,t1.最长的响铃时长
    ,t1.最大通话时长
    ,convert_tz(t1.routed_at, '+00:00', '+08:00') 标记时间
from
    (
        select
            a.pno
            ,a.staff_info_id
            ,a.store_id
            ,a.routed_at
            ,count(a.id) 尝试联系次数
            ,max(a.diao_num) 最长的响铃时长
            ,min(a.diao_num) 最短响铃时长
            ,max(a.call_num) 最大通话时长
        from a1 a
        group by 1,2,3,4
    ) t1
left join
    (
        select
            a4.*
        from
            (
                select
                    a3.*
                    ,row_number() over (partition by a3.pno order by a3.num desc ) rk
                from
                    (
                        select
                            a2.pno
                            ,a2.staff_info_id
                            ,a2.store_id
                            ,a2.routed_at
                            ,a2.diao_num
                            ,count(a2.id) num
                        from a1 a2
                        group by 1,2,3,4,5
                    ) a3
            ) a4
        where
            a4.rk = 1
    ) t2 on t2.pno = t1.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.store_id and dp.stat_date = '2023-07-16'
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,pr.routed_at
                ,pr.store_id
                ,pr.staff_info_id
                ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
            from ph_staging.parcel_route pr
            where
                pr.route_action = 'DELIVERY_MARKER'
                and pr.marker_category = 16
                and pr.routed_at >= '2023-07-16 16:00:00'
                and pr.routed_at < '2023-07-17 16:00:00'
        ) a
    where
        a.rk = 1
)
, a1 as
(
    select
            t1.*
            ,pr2.extra_value
            ,pr2.id
            ,json_extract(pr2.extra_value, '$.callDuration') call_num -- 通话
            ,json_extract(pr2.extra_value, '$.diaboloDuration') diao_num -- 响铃
        from ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.routed_at >= '2023-07-16 16:00:00'
            and pr2.routed_at < '2023-07-17 16:00:00'
            and pr2.route_action = 'PHONE'
            and pr2.routed_at < t1.routed_at
)
select
    t1.pno
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,t1.staff_info_id 快递员
    ,hsi.hire_date 入职时间
    ,t1.尝试联系次数
    ,t2.diao_num 出现最多的响铃时长
    ,t1.最短响铃时长
    ,t1.最长的响铃时长
    ,t1.最大通话时长
    ,convert_tz(t1.routed_at, '+00:00', '+08:00') 标记时间
from
    (
        select
            a.pno
            ,a.staff_info_id
            ,a.store_id
            ,a.routed_at
            ,count(a.id) 尝试联系次数
            ,max(a.diao_num) 最长的响铃时长
            ,min(a.diao_num) 最短响铃时长
            ,max(a.call_num) 最大通话时长
        from a1 a
        group by 1,2,3,4
    ) t1
left join
    (
        select
            a4.*
        from
            (
                select
                    a3.*
                    ,row_number() over (partition by a3.pno order by a3.num desc ) rk
                from
                    (
                        select
                            a2.pno
                            ,a2.staff_info_id
                            ,a2.store_id
                            ,a2.routed_at
                            ,a2.diao_num
                            ,count(a2.id) num
                        from a1 a2
                        group by 1,2,3,4,5
                    ) a3
            ) a4
        where
            a4.rk = 1
    ) t2 on t2.pno = t1.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.store_id and dp.stat_date = '2023-07-16'
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,pr.routed_at
                ,pr.store_id
                ,pr.staff_info_id
                ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
            from ph_staging.parcel_route pr
            where
                pr.route_action = 'DELIVERY_MARKER'
                and pr.marker_category = 16
                and pr.routed_at >= '2023-07-16 16:00:00'
                and pr.routed_at < '2023-07-17 16:00:00'
        ) a
    where
        a.rk = 1
)
, a1 as
(
    select
            t1.*
            ,pr2.extra_value
            ,pr2.id
            ,cast(json_extract(pr2.extra_value, '$.callDuration') as int) call_num -- 通话
            ,cast(json_extract(pr2.extra_value, '$.diaboloDuration') as int) diao_num -- 响铃
        from ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.routed_at >= '2023-07-16 16:00:00'
            and pr2.routed_at < '2023-07-17 16:00:00'
            and pr2.route_action = 'PHONE'
            and pr2.routed_at < t1.routed_at
)
select
    t1.pno
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,t1.staff_info_id 快递员
    ,hsi.hire_date 入职时间
    ,t1.尝试联系次数
    ,t2.diao_num 出现最多的响铃时长
    ,t1.最短响铃时长
    ,t1.最长的响铃时长
    ,t1.最大通话时长
    ,convert_tz(t1.routed_at, '+00:00', '+08:00') 标记时间
from
    (
        select
            a.pno
            ,a.staff_info_id
            ,a.store_id
            ,a.routed_at
            ,count(a.id) 尝试联系次数
            ,max(a.diao_num) 最长的响铃时长
            ,min(a.diao_num) 最短响铃时长
            ,max(a.call_num) 最大通话时长
        from a1 a
        group by 1,2,3,4
    ) t1
left join
    (
        select
            a4.*
        from
            (
                select
                    a3.*
                    ,row_number() over (partition by a3.pno order by a3.num desc ) rk
                from
                    (
                        select
                            a2.pno
                            ,a2.staff_info_id
                            ,a2.store_id
                            ,a2.routed_at
                            ,a2.diao_num
                            ,count(a2.id) num
                        from a1 a2
                        group by 1,2,3,4,5
                    ) a3
            ) a4
        where
            a4.rk = 1
    ) t2 on t2.pno = t1.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.store_id and dp.stat_date = '2023-07-16'
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,pr.routed_at
                ,pr.store_id
                ,pr.staff_info_id
                ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
            from ph_staging.parcel_route pr
            where
                pr.route_action = 'DELIVERY_MARKER'
                and pr.marker_category = 16
                and pr.routed_at >= '2023-07-15 16:00:00'
                and pr.routed_at < '2023-07-16 16:00:00'
        ) a
    where
        a.rk = 1
)
, a1 as
(
    select
            t1.*
            ,pr2.extra_value
            ,pr2.id
            ,cast(json_extract(pr2.extra_value, '$.callDuration') as int) call_num -- 通话
            ,cast(json_extract(pr2.extra_value, '$.diaboloDuration') as int) diao_num -- 响铃
        from ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.routed_at >= '2023-07-15 16:00:00'
            and pr2.routed_at < '2023-07-16 16:00:00'
            and pr2.route_action = 'PHONE'
            and pr2.routed_at < t1.routed_at
)
select
    t1.pno
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,t1.staff_info_id 快递员
    ,hsi.hire_date 入职时间
    ,t1.尝试联系次数
    ,t2.diao_num 出现最多的响铃时长
    ,t1.最短响铃时长
    ,t1.最长的响铃时长
    ,t1.最大通话时长
    ,convert_tz(t1.routed_at, '+00:00', '+08:00') 标记时间
from
    (
        select
            a.pno
            ,a.staff_info_id
            ,a.store_id
            ,a.routed_at
            ,count(a.id) 尝试联系次数
            ,max(a.diao_num) 最长的响铃时长
            ,min(a.diao_num) 最短响铃时长
            ,max(a.call_num) 最大通话时长
        from a1 a
        group by 1,2,3,4
    ) t1
left join
    (
        select
            a4.*
        from
            (
                select
                    a3.*
                    ,row_number() over (partition by a3.pno order by a3.num desc ) rk
                from
                    (
                        select
                            a2.pno
                            ,a2.staff_info_id
                            ,a2.store_id
                            ,a2.routed_at
                            ,a2.diao_num
                            ,count(a2.id) num
                        from a1 a2
                        group by 1,2,3,4,5
                    ) a3
            ) a4
        where
            a4.rk = 1
    ) t2 on t2.pno = t1.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.store_id and dp.stat_date = '2023-07-16'
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
select
        a.*
    from
        (
            select
                pr.pno
                ,pr.routed_at
                ,pr.store_id
                ,pr.staff_info_id
                ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
            from ph_staging.parcel_route pr
            where
                pr.route_action = 'DELIVERY_MARKER'
                and pr.marker_category = 16
                and pr.routed_at >= '2023-07-15 16:00:00'
                and pr.routed_at < '2023-07-16 16:00:00'
        ) a
    where
        a.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name
    ,ds.pno
    ,if(f.pno is not null , '是', '否') 是否有提成
from ph_bi.dc_should_delivery_today ds
left join ph_staging.sys_store ss on ss.id = ds.store_id
left join ph_bi.finance_keeper_month_parcel_v3 f on f.pno = ds.pno and f.stat_date = ds.stat_date
where
    ds.stat_date = '2023-07-15'
    and ss.name in ('ILD_SP', 'CBS_SP', 'PGD_SP');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
        when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
        when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
        when hsi2.`state` =2 then '离职'
        when hsi2.`state` =3 then '停职'
    end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-16 16:00:00'
        and ldr.created_at < '2023-07-17 16:00:00'
)
select
    t1.*
    ,dev.staff_num 设备登录账号数
    ,if(stl.staff_info_id is null, '否', '是') 是否短信验证
from t t1
left join
    (
        select
            t1.device_id
            ,count(distinct t1.staff_info_id) staff_num
        from  t t1
        group by 1
    ) dev on dev.device_id = t1.device_id
left join ph_backyard.staff_todo_list stl on t1.staff_info_id = stl.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        dp.store_name
        ,dp.store_id
        ,dp.store_category
        ,ds.store_delivery_frequency
        ,dp.piece_name
        ,dp.region_name
        ,ds.pno
        ,ds.arrival_scan_route_at
        ,ds.vehicle_time
        ,case
            when ds.store_delivery_frequency = 1 then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and  ds.arrival_scan_route_at < '2023-07-15 10:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-15 10:00:00' then 2
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at < '2023-07-15 09:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-15 09:00:00' then 2
        end delivery_fre
    from ph_bi.dc_should_delivery_today ds
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ds.store_id and dp.stat_date =date_sub(curdate(), interval 1 day)
    where
        ds.stat_date = '2023-07-15'
        and if(ds.original_store_id is null , 1 = 1, ds.original_store_id != ds.store_id)
)
,sort as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,convert_tz(pr.routed_at, '+00:00', '+08:00') rou_time
                ,row_number() over (partition by pr.pno order by pr.routed_at) rk
            from ph_staging.parcel_route pr
            join t t1 on t1.pno = pr.pno and pr.store_id = t1.store_id
            where
                pr.route_action = 'SORTING_SCAN'
        ) a
    where
        a.rk = 1
)

select
    t1.store_name 网点
    ,t1.store_id 网点ID
    ,if(t1.store_category != 14, '是', '否') 是否提成考核
    ,case t1.store_category
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
    ,case t1.store_delivery_frequency
        when 1 then '一派'
        when 2 then '二派'
    end '一派/二派'
    ,t1.piece_name 片区
    ,t1.region_name 大区
    ,count(t1.pno) 应派总量
    ,count(if(f.pno is not null and s2.pno is not null, t1.pno, null)) 总有效分拣扫描数
    ,count(if(s2.rou_time is not null , t1.pno, null))/count(t1.pno) 总分拣扫描率
    ,count(if(f.pno is not null and s2.pno is not null, t1.pno, null))/count(t1.pno) 总有效分拣扫描率
    ,count(if(t1.delivery_fre = 1, t1.pno, null)) 一派应派件数
    ,ve1.max_veh_time 一派最晚到港时间
    ,count(if(t1.delivery_fre = 1 and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派分拣扫描率
    ,count(if(t1.delivery_fre = 1 and f.pno is not null and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派有效分拣扫描率
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 08:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0800前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 08:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0830前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 09:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0900前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 09:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0930前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-15 10:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 1000前占比
    ,count(if(t1.delivery_fre = 2, t1.pno, null)) 二派应派件数
    ,ve2.max_veh_time 二派最晚到港时间
    ,count(if(t1.delivery_fre = 2 and f.pno is not null and s2.pno is not null, t1.pno, null )) 二派有效分拣数
    ,count(if(t1.delivery_fre = 2 and s2.pno is not null , t1.pno, null ))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派分拣扫描率
    ,count(if(t1.delivery_fre = 2 and f.pno is not null and s2.pno is not null, t1.pno, null))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派有效分拣扫描率
from t t1
left join sort s2 on t1.pno = s2.pno
left join ph_bi.finance_keeper_month_parcel_v3 f on f.pno = t1.pno and f.store_id = t1.store_id and f.stat_date = '2023-07-15' and f.type = 2
left join
    (
        select
            t1.store_id
            ,max(t1.vehicle_time) max_veh_time
        from t t1
        where
            t1.delivery_fre = 1
        group by 1
    ) ve1 on ve1.store_id = t1.store_id
left join
    (
        select
            t1.store_id
            ,max(t1.vehicle_time) max_veh_time
        from t t1
        where
            t1.delivery_fre = 2
        group by 1
    ) ve2 on ve2.store_id = t1.store_id
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        dp.store_name
        ,dp.store_id
        ,dp.store_category
        ,ds.store_delivery_frequency
        ,dp.piece_name
        ,dp.region_name
        ,ds.pno
        ,ds.arrival_scan_route_at
        ,ds.vehicle_time
        ,case
            when ds.store_delivery_frequency = 1 then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and  ds.arrival_scan_route_at < '2023-07-16 10:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time = '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-16 10:00:00' then 2
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at < '2023-07-16 09:00:00' then 1
            when ds.store_delivery_frequency = 2 and ds.vehicle_time != '1970-01-01 00:00:00' and ds.arrival_scan_route_at >= '2023-07-16 09:00:00' then 2
        end delivery_fre
    from ph_bi.dc_should_delivery_today ds
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ds.store_id and dp.stat_date =date_sub(curdate(), interval 1 day)
    where
        ds.stat_date = '2023-07-16'
        and if(ds.original_store_id is null , 1 = 1, ds.original_store_id != ds.store_id)
)
,sort as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,convert_tz(pr.routed_at, '+00:00', '+08:00') rou_time
                ,row_number() over (partition by pr.pno order by pr.routed_at) rk
            from ph_staging.parcel_route pr
            join t t1 on t1.pno = pr.pno and pr.store_id = t1.store_id
            where
                pr.route_action = 'SORTING_SCAN'
        ) a
    where
        a.rk = 1
)

select
    t1.store_name 网点
    ,t1.store_id 网点ID
    ,if(t1.store_category != 14, '是', '否') 是否提成考核
    ,case t1.store_category
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
    ,case t1.store_delivery_frequency
        when 1 then '一派'
        when 2 then '二派'
    end '一派/二派'
    ,t1.piece_name 片区
    ,t1.region_name 大区
    ,count(t1.pno) 应派总量
    ,count(if(f.pno is not null and s2.pno is not null, t1.pno, null)) 总有效分拣扫描数
    ,count(if(s2.rou_time is not null , t1.pno, null))/count(t1.pno) 总分拣扫描率
    ,count(if(f.pno is not null and s2.pno is not null, t1.pno, null))/count(t1.pno) 总有效分拣扫描率
    ,count(if(t1.delivery_fre = 1, t1.pno, null)) 一派应派件数
    ,ve1.max_veh_time 一派最晚到港时间
    ,count(if(t1.delivery_fre = 1 and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派分拣扫描率
    ,count(if(t1.delivery_fre = 1 and f.pno is not null and s2.pno is not null, t1.pno, null ))/count(if(t1.delivery_fre = 1, t1.pno, null)) 一派有效分拣扫描率
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-16 08:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0800前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-16 08:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0830前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-16 09:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0900前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-16 09:30:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 0930前占比
    ,count(if(t1.delivery_fre = 1 and s2.rou_time < '2023-07-16 10:00:00', t1.pno, null))/count(if(t1.delivery_fre = 1, t1.pno, null)) 1000前占比
    ,count(if(t1.delivery_fre = 2, t1.pno, null)) 二派应派件数
    ,ve2.max_veh_time 二派最晚到港时间
    ,count(if(t1.delivery_fre = 2 and f.pno is not null and s2.pno is not null, t1.pno, null )) 二派有效分拣数
    ,count(if(t1.delivery_fre = 2 and s2.pno is not null , t1.pno, null ))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派分拣扫描率
    ,count(if(t1.delivery_fre = 2 and f.pno is not null and s2.pno is not null, t1.pno, null))/count(if(t1.delivery_fre = 2, t1.pno, null)) 二派有效分拣扫描率
from t t1
left join sort s2 on t1.pno = s2.pno
left join ph_bi.finance_keeper_month_parcel_v3 f on f.pno = t1.pno and f.store_id = t1.store_id and f.stat_date = '2023-07-16' and f.type = 2
left join
    (
        select
            t1.store_id
            ,max(t1.vehicle_time) max_veh_time
        from t t1
        where
            t1.delivery_fre = 1
        group by 1
    ) ve1 on ve1.store_id = t1.store_id
left join
    (
        select
            t1.store_id
            ,max(t1.vehicle_time) max_veh_time
        from t t1
        where
            t1.delivery_fre = 2
        group by 1
    ) ve2 on ve2.store_id = t1.store_id
group by 1,2,3,4;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,dp.piece_name 片区
        ,dp.region_name 大区
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.staff_info_id order by ldr.created_at) rk
        ,row_number() over (order by ldr.created_at ) rn
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ss.id and dp.stat_date = date_sub(curdate(), interval 1 day)
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-16 16:00:00'
        and ldr.created_at < '2023-07-17 16:00:00'
)
, staff as
(
    select
        t1.*
        ,min(t2.登录时间) other_login_time
    from t t1
    left join t t2 on t2.device_id = t1.device_id
    where
        t2.staff_info_id != t1.staff_info_id
        and t2.登录时间 > t1.登录时间
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
)

, b as
(
    select
        t1.*
        ,ds.handover_par_cnt 员工当日交接包裹数
        ,dev.staff_num 设备登录账号数
        ,pr.pno 交接包裹单号
        ,case pi.state
            when 1 then '已揽收'
            when 2 then '运输中'
            when 3 then '派送中'
            when 4 then '已滞留'
            when 5 then '已签收'
            when 6 then '疑难件处理中'
            when 7 then '已退件'
            when 8 then '异常关闭'
            when 9 then '已撤销'
        end 交接包裹当前状态
        ,pr.routed_at
        ,s2.other_login_time
        ,t2.登录时间 t2_登录时间
        ,least(s2.other_login_time, t2.登录时间) 最小时间
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
        ,row_number() over (partition by t1.device_id,pr.pno, pr.staff_info_id order by pr.routed_at desc) rnk
        ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
    from t t1
    left join t t2 on t2.staff_info_id = t1.staff_info_id and t2.rk = t1.rk + 1
    left join staff s2 on s2.rn = t1.rn
    left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-14'
    left join
        (
            select
                t1.device_id
                ,count(distinct t1.staff_info_id) staff_num
            from  t t1
            group by 1
        ) dev on dev.device_id = t1.device_id
    left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(least(s2.other_login_time, t2.登录时间), interval 8 hour)
    left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
, pr as
(
    select
        pr2.pno
        ,pr2.staff_info_id
        ,pr2.routed_at
        ,row_number() over (partition by pr2.pno order by pr2.routed_at ) rk
    from ph_staging.parcel_route pr2
    where
        pr2.routed_at >= '2023-07-16 16:00:00'
        and pr2.routed_at < '2023-07-17 16:00:00'
        and pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    )
select
    b1.*
    ,pr1.rk 本次交接是此包裹当天的第几次交接
    ,if(pr2.staff_info_id is not null, if(pr2.staff_info_id = b1.staff_info_id , '是', '否'), '' ) 包裹上一交接人是否是此人
from
    (
        select
            *
        from b b1
        where
            if(b1.sc_time is null , 1 = 1, b1.rnk = 1)
    ) b1
left join pr pr1 on pr1.pno = b1.交接包裹单号 and pr1.routed_at = b1.routed_at
left join pr pr2 on pr2.pno = pr1.pno and pr2.rk = pr1.rk - 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.ticket_delivery_store_id
    from ph_staging.parcel_info pi
    left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
    left join ph_bi.finance_keeper_month_parcel_v3 f on f.pno = pi.pno and f.store_id = pi.ticket_delivery_store_id and f.type = 2
    where
        pi.state = 5
        and ss.name in ('ILD_SP', 'CBS_SP', 'PGD_SP')
        and f.pno is null
        and pi.finished_at >= '2023-07-14 16:00:00'
        and pi.finished_at < '2023-07-15 16:00:00'
)
select
    t1.ticket_delivery_store_id
    ,t1.pno
    ,if(aws.routed_at < '2023-07-13 16:00:00', '是', '否') 是否在0714之前到达
    ,if(lx.pno is not null , '是', '否') 是否有正确路由组合排序
from t t1
left join
    (
        select
            t1.ticket_delivery_store_id
            ,t1.pno
        from t t1
        # left join
        #     (
        #         select
        #             pr.pno
        #             ,pr.routed_at
        #         from ph_staging.parcel_route pr
        #         join t t1 on t1.pno = pr.pno
        #         where
        #             pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
        #             and pr.store_id in ('PH35500A00', 'PH32170200', 'PH45140300')
        #     ) aws on aws.pno = t1.pno
        left join
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,pr.routed_at
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.route_action = 'SORTING_SCAN'
            ) sc on sc.pno = t1.pno and sc.store_id = t1.ticket_delivery_store_id
        left join
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,pr.routed_at
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            ) dtc on dtc.pno = t1.pno and dtc.store_id = t1.ticket_delivery_store_id
        left join
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,pr.routed_at
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.route_action = 'DELIVERY_CONFIRM'
            ) dc on dc.pno = t1.pno and dc.store_id = t1.ticket_delivery_store_id
        where
            sc.routed_at < dtc.routed_at
            and dtc.routed_at < dc.routed_at
        group by 1,2
    ) lx on lx.pno = t1.pno and lx.ticket_delivery_store_id = t1.ticket_delivery_store_id
left join
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.routed_at
            ,row_number() over (partition by pr.store_id, pr.pno order by pr.routed_at) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    ) aws on aws.pno = t1.pno and aws.store_id = t1.ticket_delivery_store_id and aws.rk = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,pr.routed_at
                ,pr.store_id
                ,pr.staff_info_id
                ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
            from ph_staging.parcel_route pr
            where
                pr.route_action = 'DELIVERY_MARKER'
                and pr.marker_category = 1
                and pr.routed_at >= '2023-07-15 16:00:00'
                and pr.routed_at < '2023-07-16 16:00:00'
        ) a
    where
        a.rk = 1
)
, a1 as
(
    select
            t1.*
            ,pr2.extra_value
            ,pr2.id
            ,cast(json_extract(pr2.extra_value, '$.callDuration') as int) call_num -- 通话
            ,cast(json_extract(pr2.extra_value, '$.diaboloDuration') as int) diao_num -- 响铃
        from ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.routed_at >= '2023-07-15 16:00:00'
            and pr2.routed_at < '2023-07-16 16:00:00'
            and pr2.route_action = 'PHONE'
            and pr2.routed_at < t1.routed_at
)
select
    t1.pno
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,t1.staff_info_id 快递员
    ,hsi.hire_date 入职时间
    ,t1.尝试联系次数
    ,t2.diao_num 出现最多的响铃时长
    ,t1.最短响铃时长
    ,t1.最长的响铃时长
    ,t1.最大通话时长
    ,convert_tz(t1.routed_at, '+00:00', '+08:00') 标记时间
from
    (
        select
            a.pno
            ,a.staff_info_id
            ,a.store_id
            ,a.routed_at
            ,count(a.id) 尝试联系次数
            ,max(a.diao_num) 最长的响铃时长
            ,min(a.diao_num) 最短响铃时长
            ,max(a.call_num) 最大通话时长
        from a1 a
        group by 1,2,3,4
    ) t1
left join
    (
        select
            a4.*
        from
            (
                select
                    a3.*
                    ,row_number() over (partition by a3.pno order by a3.num desc ) rk
                from
                    (
                        select
                            a2.pno
                            ,a2.staff_info_id
                            ,a2.store_id
                            ,a2.routed_at
                            ,a2.diao_num
                            ,count(a2.id) num
                        from a1 a2
                        group by 1,2,3,4,5
                    ) a3
            ) a4
        where
            a4.rk = 1
    ) t2 on t2.pno = t1.pno
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.store_id and dp.stat_date = '2023-07-16'
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name
    ,ds.pno
    ,if(f.pno is not null , '是', '否') 是否有提成
from ph_bi.dc_should_delivery_today ds
left join ph_staging.sys_store ss on ss.id = ds.store_id
left join ph_bi.finance_keeper_month_parcel_v3 f on f.pno = ds.pno and f.stat_date = ds.stat_date
where
    ds.stat_date = '2023-07-15'
    and ss.name in;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.ticket_delivery_store_id
    from ph_staging.parcel_info pi
    left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
    left join ph_bi.finance_keeper_month_parcel_v3 f on f.pno = pi.pno and f.store_id = pi.ticket_delivery_store_id and f.type = 2
    where
        pi.state = 5
        and ss.name in ('ILD_SP', 'CBS_SP', 'PGD_SP')
        and f.pno is null
        and pi.finished_at >= '2023-07-14 16:00:00'
        and pi.finished_at < '2023-07-15 16:00:00'
)
select
    t1.ticket_delivery_store_id
    ,ss2.name
    ,t1.pno
    ,if(aws.routed_at < '2023-07-13 16:00:00', '是', '否') 是否在0714之前到达
    ,if(lx.pno is not null , '是', '否') 是否有正确路由组合排序
from t t1
left join
    (
        select
            t1.ticket_delivery_store_id
            ,t1.pno
        from t t1
        # left join
        #     (
        #         select
        #             pr.pno
        #             ,pr.routed_at
        #         from ph_staging.parcel_route pr
        #         join t t1 on t1.pno = pr.pno
        #         where
        #             pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
        #             and pr.store_id in ('PH35500A00', 'PH32170200', 'PH45140300')
        #     ) aws on aws.pno = t1.pno
        left join
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,pr.routed_at
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.route_action = 'SORTING_SCAN'
            ) sc on sc.pno = t1.pno and sc.store_id = t1.ticket_delivery_store_id
        left join
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,pr.routed_at
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            ) dtc on dtc.pno = t1.pno and dtc.store_id = t1.ticket_delivery_store_id
        left join
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,pr.routed_at
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.route_action = 'DELIVERY_CONFIRM'
            ) dc on dc.pno = t1.pno and dc.store_id = t1.ticket_delivery_store_id
        where
            sc.routed_at < dtc.routed_at
            and dtc.routed_at < dc.routed_at
        group by 1,2
    ) lx on lx.pno = t1.pno and lx.ticket_delivery_store_id = t1.ticket_delivery_store_id
left join
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.routed_at
            ,row_number() over (partition by pr.store_id, pr.pno order by pr.routed_at) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    ) aws on aws.pno = t1.pno and aws.store_id = t1.ticket_delivery_store_id and aws.rk = 1
left join ph_staging.sys_store ss2 on ss2.id = t1.ticket_delivery_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
        pi.pno
        ,pi.ticket_delivery_store_id
    from ph_bi.dc_should_delivery_today ds
    left join ph_staging.parcel_info pi on ds.pno = pi.pno
    left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
    left join ph_bi.finance_keeper_month_parcel_v3 f on f.pno = pi.pno and f.store_id = pi.ticket_delivery_store_id and f.type = 2
    where
        pi.state = 5
        and ds.stat_date = '2023-07-15'
        and ss.name in ('ILD_SP', 'CBS_SP', 'PGD_SP')
        and f.pno is null
        and pi.finished_at >= '2023-07-14 16:00:00'
        and pi.finished_at < '2023-07-15 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.ticket_delivery_store_id
    from ph_bi.dc_should_delivery_today ds
    left join ph_staging.parcel_info pi on ds.pno = pi.pno
    left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
    left join ph_bi.finance_keeper_month_parcel_v3 f on f.pno = pi.pno and f.store_id = pi.ticket_delivery_store_id and f.type = 2
    where
        pi.state = 5
        and ds.stat_date = '2023-07-15'
        and ss.name in ('ILD_SP', 'CBS_SP', 'PGD_SP')
        and f.pno is null
        and pi.finished_at >= '2023-07-14 16:00:00'
        and pi.finished_at < '2023-07-15 16:00:00'
)
select
    t1.ticket_delivery_store_id
    ,ss2.name
    ,t1.pno
    ,if(aws.routed_at < '2023-07-13 16:00:00', '是', '否') 是否在0714之前到达
    ,if(lx.pno is not null , '是', '否') 是否有正确路由组合排序
from t t1
left join
    (
        select
            t1.ticket_delivery_store_id
            ,t1.pno
        from t t1
        # left join
        #     (
        #         select
        #             pr.pno
        #             ,pr.routed_at
        #         from ph_staging.parcel_route pr
        #         join t t1 on t1.pno = pr.pno
        #         where
        #             pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
        #             and pr.store_id in ('PH35500A00', 'PH32170200', 'PH45140300')
        #     ) aws on aws.pno = t1.pno
        left join
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,pr.routed_at
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.route_action = 'SORTING_SCAN'
            ) sc on sc.pno = t1.pno and sc.store_id = t1.ticket_delivery_store_id
        left join
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,pr.routed_at
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            ) dtc on dtc.pno = t1.pno and dtc.store_id = t1.ticket_delivery_store_id
        left join
            (
                select
                    pr.pno
                    ,pr.store_id
                    ,pr.routed_at
                from ph_staging.parcel_route pr
                join t t1 on t1.pno = pr.pno
                where
                    pr.route_action = 'DELIVERY_CONFIRM'
            ) dc on dc.pno = t1.pno and dc.store_id = t1.ticket_delivery_store_id
        where
            sc.routed_at < dtc.routed_at
            and dtc.routed_at < dc.routed_at
        group by 1,2
    ) lx on lx.pno = t1.pno and lx.ticket_delivery_store_id = t1.ticket_delivery_store_id
left join
    (
        select
            pr.pno
            ,pr.store_id
            ,pr.routed_at
            ,row_number() over (partition by pr.store_id, pr.pno order by pr.routed_at) rk
        from ph_staging.parcel_route pr
        join t t1 on t1.pno = pr.pno
        where
            pr.route_action = 'ARRIVAL_WAREHOUSE_SCAN'
    ) aws on aws.pno = t1.pno and aws.store_id = t1.ticket_delivery_store_id and aws.rk = 1
left join ph_staging.sys_store ss2 on ss2.id = t1.ticket_delivery_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name
    ,count(ds.pno)
from ph_bi.dc_should_delivery_today ds
left join ph_staging.parcel_info pi on ds.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join ph_bi.finance_keeper_month_parcel_v3 f on f.pno = pi.pno and f.store_id = pi.ticket_delivery_store_id and f.type = 2
where
    pi.state = 5
    and ds.stat_date = '2023-07-15'
    and ss.name in ('ILD_SP', 'CBS_SP', 'PGD_SP');
;-- -. . -..- - / . -. - .-. -.--
select
    ss.name
    ,count(ds.pno)
from ph_bi.dc_should_delivery_today ds
left join ph_staging.parcel_info pi on ds.pno = pi.pno
left join ph_staging.sys_store ss on ss.id = pi.ticket_delivery_store_id
left join ph_bi.finance_keeper_month_parcel_v3 f on f.pno = pi.pno and f.store_id = pi.ticket_delivery_store_id and f.type = 2
where
    pi.state = 5
    and ds.stat_date = '2023-07-15'
    and ss.name in ('ILD_SP', 'CBS_SP', 'PGD_SP')
#     and f.pno is null
#     and pi.finished_at >= '2023-07-14 16:00:00'
#     and pi.finished_at < '2023-07-15 16:00:00'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        a.*
    from
        (
            select
                pr.pno
                ,pr.routed_at
                ,pr.store_id
                ,pr.staff_info_id
                ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
            from ph_staging.parcel_route pr
            where
                pr.route_action = 'DELIVERY_MARKER'
                and pr.marker_category = 1
                and pr.routed_at >= '2023-07-15 16:00:00'
                and pr.routed_at < '2023-07-16 16:00:00'
        ) a
    where
        a.rk = 1
)
, a1 as
(
    select
        t1.*
        ,pr2.extra_value
        ,pr2.id
        ,pr2.routed_at phone_time
        ,cast(json_extract(pr2.extra_value, '$.callDuration') as int) call_num -- 通话
        ,cast(json_extract(pr2.extra_value, '$.diaboloDuration') as int) diao_num -- 响铃
    from ph_staging.parcel_route pr2
    join t t1 on t1.pno = pr2.pno
    where
        pr2.routed_at >= '2023-07-15 16:00:00'
        and pr2.routed_at < '2023-07-16 16:00:00'
        and pr2.route_action = 'PHONE'
        and pr2.routed_at < t1.routed_at
)
select
    t1.pno
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,t1.staff_info_id 快递员
    ,hsi.hire_date 入职时间
    ,t1.尝试联系次数
    ,t2.diao_num 出现最多的响铃时长
    ,t1.最短响铃时长
    ,t1.最长的响铃时长
    ,t1.最大通话时长
    ,timestampdiff(second, fir.phone_time, las.phone_time)/3600 间隔时间_h
    ,convert_tz(t1.routed_at, '+00:00', '+08:00') 标记时间
from
    (
        select
            a.pno
            ,a.staff_info_id
            ,a.store_id
            ,a.routed_at
            ,count(a.id) 尝试联系次数
            ,max(a.diao_num) 最长的响铃时长
            ,min(a.diao_num) 最短响铃时长
            ,max(a.call_num) 最大通话时长
        from a1 a
        group by 1,2,3,4
    ) t1
left join
    (
        select
            a4.*
        from
            (
                select
                    a3.*
                    ,row_number() over (partition by a3.pno order by a3.num desc ) rk
                from
                    (
                        select
                            a2.pno
                            ,a2.staff_info_id
                            ,a2.store_id
                            ,a2.routed_at
                            ,a2.diao_num
                            ,count(a2.id) num
                        from a1 a2
                        group by 1,2,3,4,5
                    ) a3
            ) a4
        where
            a4.rk = 1
    ) t2 on t2.pno = t1.pno
left join
    (
        select
            a.*
            ,row_number() over (partition by a.pno order by a.phone_time ) rn
        from a1 a
    ) fir on fir.pno = t1.pno and fir.rn = 1
left join
    (
        select
            a.*
            ,row_number() over (partition by a.pno order by a.phone_time desc ) rn
        from a1 a
    ) las on las.pno = t1.pno and las.rn = 1
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = t1.store_id and dp.stat_date = '2023-07-16'
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_info_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        de.pno
        ,de.dst_store_id
        ,de.dst_store
        ,de.dst_region
        ,de.dst_piece
        ,pi.state
        ,pi.dst_phone
        ,pi.dst_home_phone
    from dwm.dwd_ex_ph_parcel_details de
    left join ph_staging.parcel_info pi on de.pno = pi.pno
    left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
    left join ph_staging.parcel_route pr on pr.pno = de.pno and pr.route_action = 'PENDING_RETURN'
    where
        datediff(now(), de.dst_routed_at) <= 7
        and pi.state not in (5,7,8,9)
        and bc.client_id is null
        and pr.pno is null
    group by 1
)
select
    t1.pno
    ,t1.dst_store 目的地网点
    ,t1.dst_store_id 目的网点ID
    ,t1.dst_piece 目的地片区
    ,t1.dst_region 目的地大区
    ,case t1.state
        when '1' then '已揽收'
        when '2' then '运输中'
        when '3' then '派送中'
        when '4' then '已滞留'
        when '5' then '已签收'
        when '6' then '疑难件处理中'
        when '7' then '已退件'
        when '8' then '异常关闭'
        when '9' then '已撤销'
    end as `包裹状态`
    ,t1.dst_phone 收件人电话
    ,t1.dst_home_phone 收件人家庭电话
    ,count(distinct ppd.mark_date) 尝试天数
from t t1
left join
    (
        select
            td.pno
            ,date(convert_tz(tdm.created_at, '+00:00', '+08:00')) mark_date
        from ph_staging.ticket_delivery td
        join t t1 on t1.pno = td.pno
        left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
        group by 1,2
    ) mark on mark.pno = t1.pno
left join
    (
        select
            ppd.pno
            ,date(convert_tz(ppd.created_at, '+00:00', '+08:00')) mark_date
        from ph_staging.parcel_problem_detail ppd
        join t t1 on t1.pno = ppd.pno
        where
            ppd.diff_marker_category not in (7,22,5,20,6,21,15,71)
        group by 1,2
    ) ppd on ppd.pno = mark.pno and mark.mark_date = ppd.mark_date
left join
    (
        select
            ppd.pno
            ,date(convert_tz(ppd.created_at, '+00:00', '+08:00')) mark_date
        from ph_staging.parcel_problem_detail ppd
        join t t1 on t1.pno = ppd.pno
        where
            ppd.diff_marker_category not in (7,22,5,20,6,21,15,71)
            and ppd.created_at > '2023-07-17 16:00:00'
        group by 1,2
    ) pd on pd.pno = t1.pno
where
    ppd.mark_date is not null
    and pd.pno is not null
group by 1
having count(distinct ppd.mark_date) = 3;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,hsi3.name submitter_name
    ,hjt2.job_name submitter_job
    ,ra.report_id
    ,concat(tp.cn, tp.eng) reason
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') picture
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join ph_bi.hr_staff_info hsi3 on hsi3.staff_info_id = ra.submitter_id
left join ph_bi.hr_job_title hjt2 on hjt2.id = hsi3.job_title
left join tmpale.tmp_ph_report_reason tp on tp.key = ra.reason
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id and sa.oss_bucket_type = 'REPORT_AUDIT_IMG'
where
    ra.created_at >= '2023-07-10' -- 玺哥不看之前的数据
    and ra.status = 2
    and ra.final_approval_time >= date_sub(curdate(), interval 11 hour)
    and ra.final_approval_time < date_add(curdate(), interval 13 hour )
#     and ra.final_approval_time >= '2023-07-14 14:00:00'
#     and ra.final_approval_time < '2023-07-16 14:00:00'
group by 1
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,a1.id 举报记录ID
    ,a1.submitter_id 举报人工号
    ,a1.submitter_name 举报人姓名
    ,a1.submitter_job 举报人职位
    ,hsi.name 被举报人姓名
    ,date(hsi.hire_date) 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.reason 举报原因
    ,a1.remark 事情描述
    ,a1.picture 图片
    ,hsi.mobile 手机号

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,case
        when smr.name in ('Area3', 'Area6') then '彭万松'
        when smr.name in ('Area4', 'Area9') then '韩钥'
        when smr.name in ('Area7', 'Area8','Area10', 'Area11','FHome') then '张可新'
        when smr.name in ('Area1', 'Area2','Area5', 'Area12') then '李俊'
    end 负责人
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 2;
;-- -. . -..- - / . -. - .-. -.--
with d as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from ph_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-17'
        and ds.stat_date <= '2023-07-17'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
, t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from d ds
    left join
        (
            select
                pr.pno
                ,ds.stat_date
                ,max(convert_tz(pr.routed_at,'+00:00','+08:00')) remote_marker_time
            from ph_staging.parcel_route pr
            join d ds on pr.pno = ds.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date, interval 8 hour)
                and pr.routed_at < date_add(ds.stat_date, interval 16 hour)
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and pr.marker_category in (42,43) ##岛屿,偏远地区
            group by 1,2
        ) pr1  on ds.pno = pr1.pno and ds.stat_date = pr1.stat_date  #当日留仓标记为偏远地区留待次日派送
    left join
        (
            select
               pr.pno
                ,ds.stat_date
               ,convert_tz(pr.routed_at,'+00:00','+08:00') reschedule_marker_time
               ,row_number() over(partition by ds.stat_date, pr.pno order by pr.routed_at desc) rk
            from ph_staging.parcel_route pr
            join d ds on ds.pno = pr.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date ,interval 15 day)
                and pr.routed_at <  date_sub(ds.stat_date ,interval 8 hour) #限定当日之前的改约
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and from_unixtime(json_extract(pr.extra_value,'$.desiredat')) > date_add(ds.stat_date, interval 16 hour)
                and pr.marker_category in (9,14,70) ##客户改约时间
        ) pr2 on ds.pno = pr2.pno and  and  pr2.rk = 1 #当日之前客户改约时间
    left join ph_bi.dc_should_delivery_today ds1 on ds.pno = ds1.pno and ds1.state = 6 and ds1.stat_date = date_sub(ds.stat_date,interval 1 day)
    where
        case
            when pr1.pno is not null then 'N'
            when pr2.pno is not null then 'N'
            when ds1.pno is not null  then 'N'  else 'Y'
        end = 'Y'
)
, b as
(

        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,dp.store_name 网点名称
            ,case
                when dp.region_name in ('Area3', 'Area6') then '彭万松'
                when dp.region_name in ('Area4', 'Area9') then '韩钥'
                when dp.region_name in ('Area7','Area10', 'Area11','FHome') then '张可新'
                when dp.region_name in ( 'Area8') then '黄勇'
                when dp.region_name in ('Area1', 'Area2','Area5', 'Area12') then '李俊'
            end 区域
            ,dp.region_name 大区
            ,dp.piece_name 片区
            ,a.应交接
            ,a.已交接
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率
                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from ph_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        join
            (
                select
                    sd.store_id
                from ph_staging.sys_district sd
                where
                    sd.deleted = 0
                    and sd.store_id is not null
                group by 1

                union all

                select
                    sd.separation_store_id store_id
                from ph_staging.sys_district sd
                where
                    sd.deleted = 0
                    and sd.separation_store_id is not null
                group by 1
            ) sd on sd.store_id = a.store_id
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        where
            dp.store_category in (1,10,13)
)
select
    t1.日期
    ,t1.大区
    ,t1.区域
    ,t1.交接评级
    ,t1.store_num 网点数
    ,t1.store_num/t2.store_num 网点占比
from
    (
        select
            b1.日期
            ,b1.区域
            ,b1.大区
            ,b1.交接评级
            ,count(b1.网点ID) store_num
        from b b1
        group by 1,2,3,4
    ) t1
left join
    (
        select
            b1.日期
            ,b1.区域
            ,b1.大区
            ,count(b1.网点ID) store_num
        from b b1
        group by 1,2,3
    ) t2 on t2.区域 = t1.区域 and t2.大区 = t1.大区 and t2.日期 = t1.日期;
;-- -. . -..- - / . -. - .-. -.--
with d as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from ph_bi.dc_should_delivery_today ds
    where
        ds.stat_date >= '2023-07-17'
        and ds.stat_date <= '2023-07-17'
        and ds.arrival_scan_route_at < concat(ds.stat_date, ' 09:00:00')
)
, t as
(
    select
         ds.store_id
        ,ds.pno
        ,ds.stat_date
    from d ds
    left join
        (
            select
                pr.pno
                ,ds.stat_date
                ,max(convert_tz(pr.routed_at,'+00:00','+08:00')) remote_marker_time
            from ph_staging.parcel_route pr
            join d ds on pr.pno = ds.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date, interval 8 hour)
                and pr.routed_at < date_add(ds.stat_date, interval 16 hour)
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and pr.marker_category in (42,43) ##岛屿,偏远地区
            group by 1,2
        ) pr1  on ds.pno = pr1.pno and ds.stat_date = pr1.stat_date  #当日留仓标记为偏远地区留待次日派送
    left join
        (
            select
               pr.pno
                ,ds.stat_date
               ,convert_tz(pr.routed_at,'+00:00','+08:00') reschedule_marker_time
               ,row_number() over(partition by ds.stat_date, pr.pno order by pr.routed_at desc) rk
            from ph_staging.parcel_route pr
            join d ds on ds.pno = pr.pno
            where 1=1
                and pr.routed_at >= date_sub(ds.stat_date ,interval 15 day)
                and pr.routed_at <  date_sub(ds.stat_date ,interval 8 hour) #限定当日之前的改约
                and pr.route_action = 'DETAIN_WAREHOUSE'
                and from_unixtime(json_extract(pr.extra_value,'$.desiredat')) > date_add(ds.stat_date, interval 16 hour)
                and pr.marker_category in (9,14,70) ##客户改约时间
        ) pr2 on ds.pno = pr2.pno and pr2.stat_date = ds.stat_date and  pr2.rk = 1 #当日之前客户改约时间
    left join ph_bi.dc_should_delivery_today ds1 on ds.pno = ds1.pno and ds1.state = 6 and ds1.stat_date = date_sub(ds.stat_date,interval 1 day)
    where
        case
            when pr1.pno is not null then 'N'
            when pr2.pno is not null then 'N'
            when ds1.pno is not null  then 'N'  else 'Y'
        end = 'Y'
)
, b as
(

        select
            a.stat_date 日期
            ,a.store_id 网点ID
            ,dp.store_name 网点名称
            ,case
                when dp.region_name in ('Area3', 'Area6') then '彭万松'
                when dp.region_name in ('Area4', 'Area9') then '韩钥'
                when dp.region_name in ('Area7','Area10', 'Area11','FHome') then '张可新'
                when dp.region_name in ( 'Area8') then '黄勇'
                when dp.region_name in ('Area1', 'Area2','Area5', 'Area12') then '李俊'
            end 区域
            ,dp.region_name 大区
            ,dp.piece_name 片区
            ,a.应交接
            ,a.已交接
            ,concat(round(a.交接率*100,2),'%') as 交接率
            ,concat(ifnull(a.a_check,''), ifnull(a.b_check,''), ifnull(a.d_check,''), ifnull(a.e_check,''),if(a.a_check is null  and a.d_check is null and a.b_check is null and a.e_check is null, 'C', '')) 交接评级
            ,concat(round(a.A_rate * 100,2),'%')  'A时段（<0930 ）'
            ,concat(round(a.B_rate * 100,2),'%') 'B时段（0930<=X<1200）'
            ,concat(round(a.C_rate * 100,2),'%')'C时段（1200<=X<1600 ）'
            ,concat(round(a.D_rate * 100,2),'%')'D时段（>=1600）'
        from
            (
                select
                    t1.store_id
                    ,t1.stat_date
                    ,count(t1.pno) 应交接
                    ,count(if(sc.pno is not null , t1.pno, null)) 已交接
                    ,count(if(sc.pno is not null , t1.pno, null))/count(t1.pno) 交接率
                    ,count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as A_rate
                    ,count(if(time(sc.route_time) >= '09:30:00' and time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as B_rate
                    ,count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as C_rate
                    ,count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) as D_rate

                    ,if(count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.95, 'A', null ) a_check
                    ,if(count(if(time(sc.route_time) < '12:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.98 and count(if(time(sc.route_time) < '09:30:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) <= 0.95, 'B', null ) b_check
                    ,if(count(if(time(sc.route_time) >= '12:00:00' and time(sc.route_time) < '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03, 'D', null ) d_check
                    ,if(count(if(time(sc.route_time) >= '16:00:00', t1.pno, null))/count(if(sc.pno is not null , t1.pno, null)) > 0.03 , 'E', null ) e_check
                from t t1
                left join
                    (
                        select
                            sc.*
                        from
                            (
                                select
                                    pr.pno
                                    ,pr.store_id
                                    ,pr.store_name
                                    ,t1.stat_date
                                    ,convert_tz(pr.routed_at, '+00:00', '+08:00') route_time
                                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) route_date
                                    ,row_number() over (partition by pr.pno,t1.stat_date order by pr.routed_at) rk
                                from ph_staging.parcel_route pr
                                join t t1 on t1.pno = pr.pno
                                where
                                    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
                                   and pr.routed_at >= date_sub(t1.stat_date, interval 8 hour)
                                  and pr.routed_at < date_add(t1.stat_date, interval 16 hour )
                            ) sc
                        where
                            sc.rk = 1
                    ) sc on sc.pno = t1.pno and t1.stat_date = sc.stat_date
                group by 1,2
            ) a
        join
            (
                select
                    sd.store_id
                from ph_staging.sys_district sd
                where
                    sd.deleted = 0
                    and sd.store_id is not null
                group by 1

                union all

                select
                    sd.separation_store_id store_id
                from ph_staging.sys_district sd
                where
                    sd.deleted = 0
                    and sd.separation_store_id is not null
                group by 1
            ) sd on sd.store_id = a.store_id
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = a.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        where
            dp.store_category in (1,10,13)
)
select
    t1.日期
    ,t1.大区
    ,t1.区域
    ,t1.交接评级
    ,t1.store_num 网点数
    ,t1.store_num/t2.store_num 网点占比
from
    (
        select
            b1.日期
            ,b1.区域
            ,b1.大区
            ,b1.交接评级
            ,count(b1.网点ID) store_num
        from b b1
        group by 1,2,3,4
    ) t1
left join
    (
        select
            b1.日期
            ,b1.区域
            ,b1.大区
            ,count(b1.网点ID) store_num
        from b b1
        group by 1,2,3
    ) t2 on t2.区域 = t1.区域 and t2.大区 = t1.大区 and t2.日期 = t1.日期;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        ldr.staff_info_id
        ,ss.name 归属网点
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
        end 网点类型
        ,dp.piece_name 片区
        ,dp.region_name 大区
        ,hjt.job_name 岗位
        ,convert_tz(ldr.created_at, '+00:00', '+08:00') 登录时间
        ,concat('(', ldr.lng, ',', ldr.lat, ')') 登录gps
        ,concat('(', ss.lng, ',', ss.lat, ')')  网点GPS
        ,st_distance_sphere(point(ldr.lng, ldr.lat), point(ss.lng, ss.lat)) 登录位置距离网点距离
        ,ldr.currentip 登录IP
        ,ldr.wifi_name wifi名称
        ,ldr.device_id
        ,ldr.pre_login_out_id 上次登录ID
        ,case
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =0 then '在职'
            when  hsi2.`state`=1 and hsi2.`wait_leave_state` =1 then '待离职'
            when hsi2.`state` =2 then '离职'
            when hsi2.`state` =3 then '停职'
        end 上次登录ID在职状态
        ,case
            when ldr.pre_login_out_id != 0  and ldr.pre_login_out_id = ldr.staff_info_id then '是'
            when ldr.pre_login_out_id != 0   and ldr.pre_login_out_id != ldr.staff_info_id then '否'
        end 是否与上次登录账号相同
        ,row_number() over (partition by ldr.staff_info_id order by ldr.created_at) rk
        ,row_number() over (order by ldr.created_at ) rn
    from ph_staging.login_device_record ldr
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ldr.staff_info_id
    left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
    left join ph_bi.staff_info si on si.id = ldr.staff_info_id
    left join ph_staging.sys_store ss on ss.id = si.store_id
    left join dwm.dim_ph_sys_store_rd dp on dp.store_id = ss.id and dp.stat_date = date_sub(curdate(), interval 1 day)
    left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = ldr.pre_login_out_id
    where
        ldr.created_at >= '2023-07-17 16:00:00'
        and ldr.created_at < '2023-07-18 16:00:00'
)
, staff as
(
    select
        t1.*
        ,min(t2.登录时间) other_login_time
    from t t1
    left join t t2 on t2.device_id = t1.device_id
    where
        t2.staff_info_id != t1.staff_info_id
        and t2.登录时间 > t1.登录时间
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
)

, b as
(
    select
        t1.*
#         ,ds.handover_par_cnt 员工当日交接包裹数
        ,dev.staff_num 设备登录账号数
        ,pr.pno 交接包裹单号
        ,case pi.state
            when 1 then '已揽收'
            when 2 then '运输中'
            when 3 then '派送中'
            when 4 then '已滞留'
            when 5 then '已签收'
            when 6 then '疑难件处理中'
            when 7 then '已退件'
            when 8 then '异常关闭'
            when 9 then '已撤销'
        end 交接包裹当前状态
        ,pr.routed_at
        ,convert_tz(pr.routed_at, '+00:00', '+08:00') sc_time
        ,row_number() over (partition by t1.device_id,pr.pno, pr.staff_info_id order by pr.routed_at desc) rnk
        ,if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00'), null ) 妥投时间
    from t t1
    left join t t2 on t2.staff_info_id = t1.staff_info_id and t2.rk = t1.rk + 1
    left join staff s2 on s2.rn = t1.rn
#     left join dwm.dwm_ph_staff_wide_s ds on ds.staff_info_id = t1.staff_info_id and ds.stat_date = '2023-07-13'
    left join
        (
            select
                t1.device_id
                ,count(distinct t1.staff_info_id) staff_num
            from  t t1
            group by 1
        ) dev on dev.device_id = t1.device_id
    left join ph_staging.parcel_route pr on pr.staff_info_id = t1.staff_info_id and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN' and pr.created_at >= date_sub(t1.登录时间, interval 8 hour) and pr.created_at < date_sub(least(s2.other_login_time, t2.登录时间), interval 8 hour)
    left join ph_staging.parcel_info pi on pr.pno = pi.pno
)
, pr as
(
    select
        pr2.pno
        ,pr2.staff_info_id
        ,pr2.routed_at
        ,row_number() over (partition by pr2.pno order by pr2.routed_at ) rk
    from ph_staging.parcel_route pr2
    where
        pr2.routed_at >= '2023-07-17 16:00:00'
        and pr2.routed_at < '2023-07-18 16:00:00'
        and pr2.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    )
select
    b1.*
    ,pr1.rk 本次交接是此包裹当天的第几次交接
    ,if(pr2.staff_info_id is not null, if(pr2.staff_info_id = b1.staff_info_id , '是', '否'), '' ) 包裹上一交接人是否是此人
from
    (
        select
            *
        from b b1
        where
            if(b1.sc_time is null , 1 = 1, b1.rnk = 1)
    ) b1
left join pr pr1 on pr1.pno = b1.交接包裹单号 and pr1.routed_at = b1.routed_at
left join pr pr2 on pr2.pno = pr1.pno and pr2.rk = pr1.rk - 1;
;-- -. . -..- - / . -. - .-. -.--
select date_sub(curdate(), interval 2 day );
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < date_sub(curdate(), interval 2 day)
                        and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id
    ,dp.store_name
    ,dp.piece_name
    ,dp.region_name
    ,case
        when hsi2.job_title in (13,110,1000) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end roles
    ,case
        when st.absence_sum = 0 and st.late_num + st.early_num <= 1 and st.late_time_sum + st.early_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3 then 'C'
        else 'B'
    end level_ss
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
            ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
            ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(t1.attendance_started_at > t1.shift_start , 'y', 'n') late_or_not
                    ,if(t1.attendance_started_at > t1.shift_start, timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
                    ,if(t1.attendance_end_at < t1.shift_end, 'y', 'n' ) early_or_not
                    ,if(t1.attendance_end_at < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < date_sub(curdate(), interval 2 day)
                        and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id
    ,dp.store_name
    ,dp.piece_name
    ,dp.region_name
    ,case
        when hsi2.job_title in (13,110,1000) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end roles
    ,case
        when st.absence_sum = 0 and st.late_num + st.early_num <= 1 and st.late_time_sum + st.early_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3 then 'C'
        else 'B'
    end level_ss
    ,st.late_num
    ,st.late_time_sum
    ,st.early_num
    ,st.early_time_sum
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
            ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
            ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(t1.attendance_started_at > t1.shift_start , 'y', 'n') late_or_not
                    ,if(t1.attendance_started_at > t1.shift_start, timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
                    ,if(t1.attendance_end_at < t1.shift_end, 'y', 'n' ) early_or_not
                    ,if(t1.attendance_end_at < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < date_sub(curdate(), interval 2 day)
                        and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id
    ,dp.store_name
    ,dp.piece_name
    ,dp.region_name
    ,case
        when hsi2.job_title in (13,110,1000) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end roles
    ,case
        when st.absence_sum = 0 and st.late_num + st.early_num <= 1 and st.late_time_sum + st.early_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3 then 'C'
        else 'B'
    end level_ss
    ,st.late_num
    ,st.late_time_sum
    ,st.early_num
    ,st.early_time_sum
    ,st.absence_sum
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
            ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
            ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(t1.attendance_started_at > t1.shift_start , 'y', 'n') late_or_not
                    ,if(t1.attendance_started_at > t1.shift_start, timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
                    ,if(t1.attendance_end_at < t1.shift_end, 'y', 'n' ) early_or_not
                    ,if(t1.attendance_end_at < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < date_sub(curdate(), interval 2 day)
                        and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id
    ,dp.store_name
    ,dp.piece_name
    ,dp.region_name
    ,case
        when hsi2.job_title in (13,110,1000) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end roles
    ,case
        when st.absence_sum = 0 and st.late_num + st.early_num <= 1 and st.late_time_sum + st.early_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3 then 'C'
        else 'B'
    end level_ss
    ,st.late_num
    ,st.late_time_sum
    ,st.early_num
    ,st.early_time_sum
    ,st.absence_sum
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
            ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
            ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
                    ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
                    ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < date_sub(curdate(), interval 2 day)
                        and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id
    ,dp.store_name
    ,dp.piece_name
    ,dp.region_name
    ,case
        when hsi2.job_title in (13,110,1000) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end roles
    ,case
        when st.absence_sum = 0 and st.late_num + st.early_num <= 1 and st.late_time_sum + st.early_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3 or st.early_num >= 3 then 'C'
        else 'B'
    end level_ss
    ,st.late_num
    ,st.late_time_sum
    ,st.early_num
    ,st.early_time_sum
    ,st.absence_sum
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
            ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
            ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
                    ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
                    ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < date_sub(curdate(), interval 2 day)
                        and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    ss.store_id 网点ID
    ,dp.store_name 网点
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,ss.num/dp.on_emp_cnt
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end store_level
from
    (
        select
            s.store_id
            ,count(if(s.ss_level = 'C', s.staff_info_id, null)) num
        from
            (
                select
                    st.staff_info_id
                    ,dp.store_id
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,case
                        when hsi2.job_title in (13,110,1000) then '快递员'
                        when hsi2.job_title in (37) then '仓管员'
                        when hsi2.job_title in (16) then '主管'
                    end roles
                    ,case
                        when st.absence_sum = 0 and st.late_num + st.early_num <= 1 and st.late_time_sum + st.early_time_sum < 30 then 'A'
                        when st.absence_sum >= 2 or st.late_num >= 3 or st.early_num >= 3 then 'C'
                        else 'B'
                    end ss_level
                from
                    (
                        select
                            a.staff_info_id
                            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
                            ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
                            ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                            ,sum(a.absence_time) absence_sum
                        from
                            (
                                select
                                    t1.*
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
                                    ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
                                    ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = ss.store_id and dp.stat_date = date_sub(curdate(), interval 1 day);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < date_sub(curdate(), interval 2 day)
                        and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    ss.store_id 网点ID
    ,dp.store_name 网点
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,ss.num/dp.on_emp_cnt
    ,ss.num
    ,dp.on_emp_cnt
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end store_level
from
    (
        select
            s.store_id
            ,count(if(s.ss_level = 'C', s.staff_info_id, null)) num
        from
            (
                select
                    st.staff_info_id
                    ,dp.store_id
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,case
                        when hsi2.job_title in (13,110,1000) then '快递员'
                        when hsi2.job_title in (37) then '仓管员'
                        when hsi2.job_title in (16) then '主管'
                    end roles
                    ,case
                        when st.absence_sum = 0 and st.late_num + st.early_num <= 1 and st.late_time_sum + st.early_time_sum < 30 then 'A'
                        when st.absence_sum >= 2 or st.late_num >= 3 or st.early_num >= 3 then 'C'
                        else 'B'
                    end ss_level
                from
                    (
                        select
                            a.staff_info_id
                            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
                            ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
                            ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                            ,sum(a.absence_time) absence_sum
                        from
                            (
                                select
                                    t1.*
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
                                    ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
                                    ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = ss.store_id and dp.stat_date = date_sub(curdate(), interval 1 day);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < date_sub(curdate(), interval 2 day)
                        and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    ss.store_id 网点ID
    ,dp.store_name 网点
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,ss.num/dp.on_emp_cnt
    ,ss.num
    ,dp.on_emp_cnt
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end store_level
from
    (
        select
            s.store_id
            ,count(if(s.ss_level = 'C', s.staff_info_id, null)) num
        from
            (
                select
                    st.staff_info_id
                    ,dp.store_id
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,case
                        when hsi2.job_title in (13,110,1000) then '快递员'
                        when hsi2.job_title in (37) then '仓管员'
                        when hsi2.job_title in (16) then '主管'
                    end roles
                    ,case
                        when st.absence_sum = 0 and st.late_num + st.early_num <= 1 and st.late_time_sum + st.early_time_sum < 30 then 'A'
                        when st.absence_sum >= 2 or st.late_num >= 3 or st.early_num >= 3 then 'C'
                        else 'B'
                    end ss_level
                from
                    (
                        select
                            a.staff_info_id
                            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
                            ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
                            ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                            ,sum(a.absence_time) absence_sum
                        from
                            (
                                select
                                    t1.*
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
                                    ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
                                    ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = ss.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    dp.on_emp_cnt > 0;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,hsi3.name submitter_name
    ,hjt2.job_name submitter_job
    ,ra.report_id
    ,concat(tp.cn, tp.eng) reason
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') picture
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join ph_bi.hr_staff_info hsi3 on hsi3.staff_info_id = ra.submitter_id
left join ph_bi.hr_job_title hjt2 on hjt2.id = hsi3.job_title
left join tmpale.tmp_ph_report_reason tp on tp.key = ra.reason
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id and sa.oss_bucket_type = 'REPORT_AUDIT_IMG'
where
#     ra.created_at >= '2023-07-10' -- 玺哥不看之前的数据
#     and ra.status = 2
#     and ra.final_approval_time >= date_sub(curdate(), interval 11 hour)
#     and ra.final_approval_time < date_add(curdate(), interval 13 hour )
    ra.report_id in ('138904','151809')
group by 1
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,a1.id 举报记录ID
    ,a1.submitter_id 举报人工号
    ,a1.submitter_name 举报人姓名
    ,a1.submitter_job 举报人职位
    ,hsi.name 被举报人姓名
    ,date(hsi.hire_date) 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.reason 举报原因
    ,a1.remark 事情描述
    ,a1.picture 图片
    ,hsi.mobile 手机号

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,case
        when smr.name in ('Area3', 'Area6') then '彭万松'
        when smr.name in ('Area4', 'Area9') then '韩钥'
        when smr.name in ('Area7', 'Area8','Area10', 'Area11','FHome') then '张可新'
        when smr.name in ('Area1', 'Area2','Area5', 'Area12') then '李俊'
    end 负责人
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.store_id
        ,pr.pno
    from ph_staging.parcel_route pr
    where
        pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 8 hour )
    group by 1,2
)
select
    t1.store_id
    ,count(distinct t1.pno) a1
    ,count(ps.third_sorting_code) a2
from t t1
left join ph_drds.parcel_sorting_code_info ps on ps.dst_store_id = t1.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.store_id
        ,pr.pno
    from ph_staging.parcel_route pr
    where
        pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 8 hour )
    group by 1,2
)
select
    t1.store_id
    ,count(distinct t1.pno) a1
    ,count(ps.third_sorting_code) a2
from t t1
left join ph_drds.parcel_sorting_code_info ps on ps.dst_store_id = t1.store_id and ps.pno = t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.store_id
        ,pr.pno
    from ph_staging.parcel_route pr
    where
        pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 8 hour )
    group by 1,2
)
select
    t1.store_id
    ,count(distinct t1.pno) a1
    ,count(ps.third_sorting_code) a2
from t t1
left join ph_drds.parcel_sorting_code_info ps on ps.dst_store_id = t1.store_id and ps.pno = t1.pno
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.store_id
        ,pr.pno
    from ph_staging.parcel_route pr
    where
        pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 8 hour )
    group by 1,2
)
select
    t1.store_id
    ,t1.pno
    ,ps.third_sorting_code
from t t1
left join ph_drds.parcel_sorting_code_info ps on ps.dst_store_id = t1.store_id and ps.pno = t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.store_id
        ,pr.pno
    from ph_staging.parcel_route pr
    where
        pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 8 hour )
    group by 1,2
)
select
    t1.store_id
    ,t1.pno
    ,ps.third_sorting_code
from t t1
left join ph_drds.parcel_sorting_code_info ps on ps.dst_store_id = t1.store_id and ps.pno = t1.pno
where
    t1.store_id = 'PH52010102';
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.store_id
        ,pr.pno
        ,pr.staff_info_id
        ,pi.state
    from ph_staging.parcel_route pr
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    where
        pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 8 hour )
    group by 1,2,3
)
select
    dr.store_id 网点ID
    ,dr.store_name 网点
    ,dr.piece_name 片区
    ,dr.region_name 大区
    ,emp_cnt.staf_num 总快递员人数
    ,att.atd_emp_cnt 总出勤快递员人数
    ,a3.del_num/att.atd_emp_cnt 平均交接量
    ,a3.del_num/att.atd_emp_cnt 平均妥投量
    ,a2.avg_code_scan 三段码平均交接量
    ,a2.avg_code_deli 三段码平均妥投量
    ,a2.avg_code_staff 三段码平均交接快递员数
    ,case
        when a2.avg_code_staff < 1.5 then 'A'
        when a2.avg_code_staff >= 1.5 and a2.avg_code_staff < 2 then 'B'
        when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'C'
        when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'D'
        when a2.avg_code_staff >= 4 then 'E'
    end 评级
from
    (
        select
            a1.store_id
            ,count(distinct a1.pno)/count(distinct a1.third_sorting_code) avg_code_scan
            ,count(distinct if(pi.state = 5, a1.pno, null))/count(distinct a1.third_sorting_code) avg_code_deli
            ,count(distinct a1.staff_info_id)/ count(distinct a1.third_sorting_code) avg_code_staff
        from
            (
                select
                    a1.*
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,ps.third_sorting_code
                            ,row_number() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        left join ph_drds.parcel_sorting_code_info ps on ps.dst_store_id = t1.store_id and ps.pno = t1.pno
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join ph_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
left join
    (
        select
           ad.sys_store_id
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
            and ad.stat_date = curdate()
       group by 1,2
    ) att on att.sys_store_id = a2.store_id
left join dwm.dim_ph_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub(curdate(), interval 1 day)
left join
    (
        select
            t1.store_id
            ,count(t1.pno) sc_num
            ,count(if(t1.state = 5, t1.pno, null)) del_num
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.store_id
        ,pr.pno
        ,pr.staff_info_id
        ,pi.state
    from ph_staging.parcel_route pr
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    where
        pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 8 hour )
    group by 1,2,3
)
select
    dr.store_id 网点ID
    ,dr.store_name 网点
    ,dr.piece_name 片区
    ,dr.region_name 大区
    ,emp_cnt.staf_num 总快递员人数
    ,att.atd_emp_cnt 总出勤快递员人数
    ,a3.del_num/att.atd_emp_cnt 平均交接量
    ,a3.del_num/att.atd_emp_cnt 平均妥投量
    ,a2.avg_code_scan 三段码平均交接量
    ,a2.avg_code_deli 三段码平均妥投量
    ,a2.avg_code_staff 三段码平均交接快递员数
    ,case
        when a2.avg_code_staff < 1.5 then 'A'
        when a2.avg_code_staff >= 1.5 and a2.avg_code_staff < 2 then 'B'
        when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'C'
        when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'D'
        when a2.avg_code_staff >= 4 then 'E'
    end 评级
from
    (
        select
            a1.store_id
            ,count(distinct a1.pno)/count(distinct a1.third_sorting_code) avg_code_scan
            ,count(distinct if(pi.state = 5, a1.pno, null))/count(distinct a1.third_sorting_code) avg_code_deli
            ,count(distinct a1.staff_info_id)/ count(distinct a1.third_sorting_code) avg_code_staff
        from
            (
                select
                    a1.*
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,ps.third_sorting_code
                            ,row_number() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        left join ph_drds.parcel_sorting_code_info ps on ps.dst_store_id = t1.store_id and ps.pno = t1.pno
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join ph_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
left join
    (
        select
           ad.sys_store_id
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
            and ad.stat_date = curdate()
       group by 1
    ) att on att.sys_store_id = a2.store_id
left join dwm.dim_ph_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub(curdate(), interval 1 day)
left join
    (
        select
            t1.store_id
            ,count(t1.pno) sc_num
            ,count(if(t1.state = 5, t1.pno, null)) del_num
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.store_id
        ,pr.pno
        ,pr.staff_info_id
        ,pi.state
    from ph_staging.parcel_route pr
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    where
        pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr.routed_at > date_sub(curdate(), interval 8 hour )
    group by 1,2,3
)
select
    dr.store_id 网点ID
    ,dr.store_name 网点
    ,dr.piece_name 片区
    ,dr.region_name 大区
    ,emp_cnt.staf_num 总快递员人数
    ,att.atd_emp_cnt 总出勤快递员人数
    ,a3.sc_num/att.atd_emp_cnt 平均交接量
    ,a3.del_num/att.atd_emp_cnt 平均妥投量
    ,a2.avg_code_scan 三段码平均交接量
    ,a2.avg_code_deli 三段码平均妥投量
    ,a2.avg_code_staff 三段码平均交接快递员数
    ,case
        when a2.avg_code_staff < 1.5 then 'A'
        when a2.avg_code_staff >= 1.5 and a2.avg_code_staff < 2 then 'B'
        when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'C'
        when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'D'
        when a2.avg_code_staff >= 4 then 'E'
    end 评级
from
    (
        select
            a1.store_id
            ,count(distinct a1.pno)/count(distinct a1.third_sorting_code) avg_code_scan
            ,count(distinct if(pi.state = 5, a1.pno, null))/count(distinct a1.third_sorting_code) avg_code_deli
            ,count(distinct a1.staff_info_id)/ count(distinct a1.third_sorting_code) avg_code_staff
        from
            (
                select
                    a1.*
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,ps.third_sorting_code
                            ,row_number() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        left join ph_drds.parcel_sorting_code_info ps on ps.dst_store_id = t1.store_id and ps.pno = t1.pno
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join ph_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
left join
    (
        select
           ad.sys_store_id
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
            and ad.stat_date = curdate()
       group by 1
    ) att on att.sys_store_id = a2.store_id
left join dwm.dim_ph_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub(curdate(), interval 1 day)
left join
    (
        select
            t1.store_id
            ,count(t1.pno) sc_num
            ,count(if(t1.state = 5, t1.pno, null)) del_num
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
        ,date(ho.start_time) start_date1
    from ph_backyard.hr_overtime ho
    where
        date(ho.start_time) >= '2023-06-01'
        and date(ho.start_time) <= '2023-06-30'
        and ho.state = 2
)
, b as
(
    select
        t1.*
        ,pr.staff_info_id
        ,ddd.CN_element
        ,pr.routed_at
        ,date(t1.start_time) start_date
        ,row_number() over (partition by pr.staff_info_id,date(t1.start_time) order by pr.routed_at desc) rk
    from ph_staging.parcel_route pr
    join t t1 on t1.staff_id = pr.staff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
    where
        pr.routed_at >= date_sub(t1.start_time, interval 8 hour)
        and pr.routed_at < date_sub(t1.end_time, interval 8 hour)
)

select
    t1.staff_id
    ,hjt.job_name 岗位
    ,case
        when t1.`type` = 1 then '工作日加班1.5倍日薪'
        when t1.`type` = 2 then 'OFF Day加班1.5倍日薪'
        when t1.`type` = 3 then 'Rest Day加班1倍日薪'
        when t1.`type` = 4 then 'Rest Day加班2倍日薪'
        when t1.`type` = 5 then '节假日加班2倍日薪'
        when t1.`type` = 6 then '节假日超时加班3倍日薪'
    end as '加班类型'
    ,t1.start_time 加班开始时间
    ,t1.end_time 加班结束时间
    ,case t1.is_anticipate
        when 0 then '后补'
        when 1 then '预申请'
    end 申请方式
    ,b1.CN_element 加班期间最后一个路由动作
    ,convert_tz(b1.routed_at, '+00:00', '+08:00') 加班期间最后一个路由时间
    ,rou.route_num 加班期间路由动作数
-- ho.`type`  as '加班类型
from t t1
left join b b1 on b1.staff_info_id = t1.staff_id and t1.start_date1 = b1.start_date and b1.start_time = t1.start_time and b1.rk = 1
left join
    (
        select
            b1.staff_id
            ,b1.start_date1
            ,b1.start_time
            ,count(b1.CN_element) route_num
        from b b1
        group by 1,2,3
    ) rou on rou.staff_id = t1.staff_id and rou.start_date1 = t1.start_date1 and rou.start_time = t1.start_time
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
        ,date(ho.start_time) start_date1
    from ph_backyard.hr_overtime ho
    where
        date(ho.start_time) >= '2023-06-01'
        and date(ho.start_time) <= '2023-06-30'
        and ho.state = 2
)
, b as
(
    select
        t1.*
        ,pr.staff_info_id
        ,ddd.CN_element
        ,pr.routed_at
        ,date(t1.start_time) start_date
        ,row_number() over (partition by pr.staff_info_id,date(t1.start_time) order by pr.routed_at desc) rk
    from ph_staging.parcel_route pr
    join t t1 on t1.staff_id = pr.staff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
    where
        pr.routed_at >= date_sub(t1.start_time, interval 8 hour)
        and pr.routed_at < date_sub(t1.end_time, interval 8 hour)
)

select
    t1.staff_id
    ,hjt.job_name 岗位
    ,case
        when t1.`type` = 1 then '工作日加班1.5倍日薪'
        when t1.`type` = 2 then 'OFF Day加班1.5倍日薪'
        when t1.`type` = 3 then 'Rest Day加班1倍日薪'
        when t1.`type` = 4 then 'Rest Day加班2倍日薪'
        when t1.`type` = 5 then '节假日加班2倍日薪'
        when t1.`type` = 6 then '节假日超时加班3倍日薪'
    end as '加班类型'
    ,t1.start_time 加班开始时间
    ,t1.end_time 加班结束时间
    ,case t1.is_anticipate
        when 0 then '后补'
        when 1 then '预申请'
    end 申请方式
    ,b1.CN_element 加班期间最后一个路由动作
    ,convert_tz(b1.routed_at, '+00:00', '+08:00') 加班期间最后一个路由时间
    ,timestampdiff(second, convert_tz(b1.routed_at, '+00:00', '+08:00'), t1.end_time) 最后一个路由动作距离加班结束时间差
    ,rou.route_num 加班期间路由动作数
-- ho.`type`  as '加班类型
from t t1
left join b b1 on b1.staff_info_id = t1.staff_id and t1.start_date1 = b1.start_date and b1.start_time = t1.start_time and b1.rk = 1
left join
    (
        select
            b1.staff_id
            ,b1.start_date1
            ,b1.start_time
            ,count(b1.CN_element) route_num
        from b b1
        group by 1,2,3
    ) rou on rou.staff_id = t1.staff_id and rou.start_date1 = t1.start_date1 and rou.start_time = t1.start_time
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
        ,date(ho.start_time) start_date1
    from ph_backyard.hr_overtime ho
    where
        date(ho.start_time) >= '2023-06-01'
        and date(ho.start_time) <= '2023-06-30'
        and ho.state = 2
)
, b as
(
    select
        t1.*
        ,pr.staff_info_id
        ,ddd.CN_element
        ,pr.routed_at
        ,date(t1.start_time) start_date
        ,row_number() over (partition by pr.staff_info_id,date(t1.start_time) order by pr.routed_at desc) rk
    from ph_staging.parcel_route pr
    join t t1 on t1.staff_id = pr.staff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
    where
        pr.routed_at >= date_sub(t1.start_time, interval 8 hour)
        and pr.routed_at < date_sub(t1.end_time, interval 8 hour)
)

select
    t1.staff_id
    ,hjt.job_name 岗位
    ,case
        when t1.`type` = 1 then '工作日加班1.5倍日薪'
        when t1.`type` = 2 then 'OFF Day加班1.5倍日薪'
        when t1.`type` = 3 then 'Rest Day加班1倍日薪'
        when t1.`type` = 4 then 'Rest Day加班2倍日薪'
        when t1.`type` = 5 then '节假日加班2倍日薪'
        when t1.`type` = 6 then '节假日超时加班3倍日薪'
    end as '加班类型'
    ,t1.start_time 加班开始时间
    ,t1.end_time 加班结束时间
    ,case t1.is_anticipate
        when 0 then '后补'
        when 1 then '预申请'
    end 申请方式
    ,b1.CN_element 加班期间最后一个路由动作
    ,convert_tz(b1.routed_at, '+00:00', '+08:00') 加班期间最后一个路由时间
    ,timestampdiff(second, convert_tz(b1.routed_at, '+00:00', '+08:00'), t1.end_time)/3600 最后一个路由动作距离加班结束时间差_hour
    ,rou.route_num 加班期间路由动作数
-- ho.`type`  as '加班类型
from t t1
left join b b1 on b1.staff_info_id = t1.staff_id and t1.start_date1 = b1.start_date and b1.start_time = t1.start_time and b1.rk = 1
left join
    (
        select
            b1.staff_id
            ,b1.start_date1
            ,b1.start_time
            ,count(b1.CN_element) route_num
        from b b1
        group by 1,2,3
    ) rou on rou.staff_id = t1.staff_id and rou.start_date1 = t1.start_date1 and rou.start_time = t1.start_time
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < date_sub(curdate(), interval 2 day)
#                         and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id 工号
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,case
        when hsi2.job_title in (13,110,1000) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end 角色
    ,case
        when st.absence_sum = 0 and st.late_num + st.early_num <= 1 and st.late_time_sum + st.early_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3 or st.early_num >= 3 then 'C'
        else 'B'
    end 出勤评级
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
            ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
            ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
                    ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
                    ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < date_sub(curdate(), interval 2 day)
                        and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    ss.store_id 网点ID
    ,dp.store_name 网点
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,ss.num/dp.on_emp_cnt C级员工占比
    ,ss.num C级快递员
    ,dp.on_emp_cnt 在职员工数
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end store_level
from
    (
        select
            s.store_id
            ,count(if(s.ss_level = 'C', s.staff_info_id, null)) num
        from
            (
                select
                    st.staff_info_id
                    ,dp.store_id
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,case
                        when hsi2.job_title in (13,110,1000) then '快递员'
                        when hsi2.job_title in (37) then '仓管员'
                        when hsi2.job_title in (16) then '主管'
                    end roles
                    ,case
                        when st.absence_sum = 0 and st.late_num + st.early_num <= 1 and st.late_time_sum + st.early_time_sum < 30 then 'A'
                        when st.absence_sum >= 2 or st.late_num >= 3 or st.early_num >= 3 then 'C'
                        else 'B'
                    end ss_level
                from
                    (
                        select
                            a.staff_info_id
                            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
                            ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
                            ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                            ,sum(a.absence_time) absence_sum
                        from
                            (
                                select
                                    t1.*
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
                                    ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
                                    ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = ss.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    dp.on_emp_cnt > 0;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
        ,date(ho.start_time) start_date1
    from ph_backyard.hr_overtime ho
    where
        date(ho.start_time) >= '2023-06-01'
        and date(ho.start_time) <= '2023-06-30'
        and ho.state = 2
        and ho.staff_id = '141214'
        and ho.start_time = '2023-06 30 13:00:00'
)
# , b as
(
    select
        t1.*
        ,pr.staff_info_id
        ,ddd.CN_element
        ,pr.routed_at
        ,date(t1.start_time) start_date
        ,row_number() over (partition by pr.staff_info_id,date(t1.start_time) order by pr.routed_at desc) rk
    from ph_staging.parcel_route pr
    join t t1 on t1.staff_id = pr.staff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
    where
        pr.routed_at >= date_sub(t1.start_time, interval 8 hour)
        and pr.routed_at < date_sub(t1.end_time, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
        ,date(ho.start_time) start_date1
    from ph_backyard.hr_overtime ho
    where
        date(ho.start_time) >= '2023-06-01'
        and date(ho.start_time) <= '2023-06-30'
        and ho.state = 2
        and ho.staff_id = '141214'
        and ho.start_time = '2023-06 30 13:00:00'
)
# , b as
# (
    select
        t1.*
        ,pr.staff_info_id
        ,ddd.CN_element
        ,pr.routed_at
        ,date(t1.start_time) start_date
        ,row_number() over (partition by pr.staff_info_id,date(t1.start_time) order by pr.routed_at desc) rk
    from ph_staging.parcel_route pr
    join t t1 on t1.staff_id = pr.staff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
    where
        pr.routed_at >= date_sub(t1.start_time, interval 8 hour)
        and pr.routed_at < date_sub(t1.end_time, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
        ,date(ho.start_time) start_date1
    from ph_backyard.hr_overtime ho
    where
        date(ho.start_time) >= '2023-06-01'
        and date(ho.start_time) <= '2023-06-30'
        and ho.state = 2
        and ho.staff_id = '141214'
        and ho.start_time = '2023-06-30 13:00:00'
)
, b as
(
    select
        t1.*
        ,pr.staff_info_id
        ,ddd.CN_element
        ,pr.routed_at
        ,date(t1.start_time) start_date
        ,row_number() over (partition by pr.staff_info_id,date(t1.start_time) order by pr.routed_at desc) rk
    from ph_staging.parcel_route pr
    join t t1 on t1.staff_id = pr.staff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
    where
        pr.routed_at >= date_sub(t1.start_time, interval 8 hour)
        and pr.routed_at < date_sub(t1.end_time, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
        ,date(ho.start_time) start_date1
    from ph_backyard.hr_overtime ho
    where
        date(ho.start_time) >= '2023-06-01'
        and date(ho.start_time) <= '2023-06-30'
        and ho.state = 2
        and ho.staff_id = '141214'
        and ho.start_time = '2023-06-30 13:00:00'
)
# , b as
# (
    select
        t1.*
        ,pr.staff_info_id
        ,ddd.CN_element
        ,pr.routed_at
        ,date(t1.start_time) start_date
        ,row_number() over (partition by pr.staff_info_id,date(t1.start_time) order by pr.routed_at desc) rk
    from ph_staging.parcel_route pr
    join t t1 on t1.staff_id = pr.staff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
    where
        pr.routed_at >= date_sub(t1.start_time, interval 8 hour)
        and pr.routed_at < date_sub(t1.end_time, interval 8 hour);
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
        ,date(ho.start_time) start_date1
    from ph_backyard.hr_overtime ho
    where
        date(ho.start_time) >= '2023-06-01'
        and date(ho.start_time) <= '2023-06-30'
        and ho.state = 2
        and ho.staff_id = '141214'
#         and ho.start_time = '2023-06-30 13:00:00'
)
, b as
(
    select
        t1.*
        ,pr.staff_info_id
        ,ddd.CN_element
        ,pr.routed_at
        ,date(t1.start_time) start_date
        ,row_number() over (partition by pr.staff_info_id,date(t1.start_time) order by pr.routed_at desc) rk
    from ph_staging.parcel_route pr
    join t t1 on t1.staff_id = pr.staff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
    where
        pr.routed_at >= date_sub(t1.start_time, interval 8 hour)
        and pr.routed_at < date_sub(t1.end_time, interval 8 hour)
)

select
    t1.staff_id
    ,hjt.job_name 岗位
    ,case
        when t1.`type` = 1 then '工作日加班1.5倍日薪'
        when t1.`type` = 2 then 'OFF Day加班1.5倍日薪'
        when t1.`type` = 3 then 'Rest Day加班1倍日薪'
        when t1.`type` = 4 then 'Rest Day加班2倍日薪'
        when t1.`type` = 5 then '节假日加班2倍日薪'
        when t1.`type` = 6 then '节假日超时加班3倍日薪'
    end as '加班类型'
    ,t1.start_time 加班开始时间
    ,t1.end_time 加班结束时间
    ,case t1.is_anticipate
        when 0 then '后补'
        when 1 then '预申请'
    end 申请方式
    ,b1.CN_element 加班期间最后一个路由动作
    ,convert_tz(b1.routed_at, '+00:00', '+08:00') 加班期间最后一个路由时间
    ,timestampdiff(second, convert_tz(b1.routed_at, '+00:00', '+08:00'), t1.end_time)/3600 最后一个路由动作距离加班结束时间差_hour
    ,rou.route_num 加班期间路由动作数
-- ho.`type`  as '加班类型
from t t1
left join b b1 on b1.staff_info_id = t1.staff_id and t1.start_date1 = b1.start_date and b1.start_time = t1.start_time and b1.rk = 1
left join
    (
        select
            b1.staff_id
            ,b1.start_date1
            ,b1.start_time
            ,count(b1.CN_element) route_num
        from b b1
        group by 1,2,3
    ) rou on rou.staff_id = t1.staff_id and rou.start_date1 = t1.start_date1 and rou.start_time = t1.start_time
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
        ,date(ho.start_time) start_date1
    from ph_backyard.hr_overtime ho
    where
        date(ho.start_time) >= '2023-06-01'
        and date(ho.start_time) <= '2023-06-30'
        and ho.state = 2
        and ho.staff_id = '141214'
#         and ho.start_time = '2023-06-30 13:00:00'
)
, b as
(
    select
        t1.*
        ,pr.staff_info_id
        ,ddd.CN_element
        ,pr.routed_at
        ,date(t1.start_time) start_date
        ,row_number() over (partition by pr.staff_info_id,date(t1.start_time) order by pr.routed_at desc) rk
    from ph_staging.parcel_route pr
    join t t1 on t1.staff_id = pr.staff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
    where
        pr.routed_at >= date_sub(t1.start_time, interval 8 hour)
        and pr.routed_at < date_sub(t1.end_time, interval 8 hour)
)

select
    t1.staff_id
    ,hjt.job_name 岗位
    ,case
        when t1.`type` = 1 then '工作日加班1.5倍日薪'
        when t1.`type` = 2 then 'OFF Day加班1.5倍日薪'
        when t1.`type` = 3 then 'Rest Day加班1倍日薪'
        when t1.`type` = 4 then 'Rest Day加班2倍日薪'
        when t1.`type` = 5 then '节假日加班2倍日薪'
        when t1.`type` = 6 then '节假日超时加班3倍日薪'
    end as '加班类型'
    ,t1.start_time 加班开始时间
    ,t1.end_time 加班结束时间
    ,case t1.is_anticipate
        when 0 then '后补'
        when 1 then '预申请'
    end 申请方式
    ,b1.CN_element 加班期间最后一个路由动作
    ,convert_tz(b1.routed_at, '+00:00', '+08:00') 加班期间最后一个路由时间
    ,timestampdiff(second, convert_tz(b1.routed_at, '+00:00', '+08:00'), t1.end_time)/3600 最后一个路由动作距离加班结束时间差_hour
    ,rou.route_num 加班期间路由动作数
-- ho.`type`  as '加班类型
from t t1
left join b b1 on b1.staff_info_id = t1.staff_id  and b1.start_time = t1.start_time and b1.rk = 1
left join
    (
        select
            b1.staff_id
            ,b1.start_date1
            ,b1.start_time
            ,count(b1.CN_element) route_num
        from b b1
        group by 1,2,3
    ) rou on rou.staff_id = t1.staff_id and rou.start_date1 = t1.start_date1 and rou.start_time = t1.start_time
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
        ,date(ho.start_time) start_date1
    from ph_backyard.hr_overtime ho
    where
        date(ho.start_time) >= '2023-06-01'
        and date(ho.start_time) <= '2023-06-30'
        and ho.state = 2
        and ho.staff_id = '141214'
#         and ho.start_time = '2023-06-30 13:00:00'
)
, b as
(
    select
        t1.*
        ,pr.staff_info_id
        ,ddd.CN_element
        ,pr.routed_at
        ,date(t1.start_time) start_date
        ,row_number() over (partition by pr.staff_info_id, t1.start_time order by pr.routed_at desc) rk
    from ph_staging.parcel_route pr
    join t t1 on t1.staff_id = pr.staff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
    where
        pr.routed_at >= date_sub(t1.start_time, interval 8 hour)
        and pr.routed_at < date_sub(t1.end_time, interval 8 hour)
)

select
    t1.staff_id
    ,hjt.job_name 岗位
    ,case
        when t1.`type` = 1 then '工作日加班1.5倍日薪'
        when t1.`type` = 2 then 'OFF Day加班1.5倍日薪'
        when t1.`type` = 3 then 'Rest Day加班1倍日薪'
        when t1.`type` = 4 then 'Rest Day加班2倍日薪'
        when t1.`type` = 5 then '节假日加班2倍日薪'
        when t1.`type` = 6 then '节假日超时加班3倍日薪'
    end as '加班类型'
    ,t1.start_time 加班开始时间
    ,t1.end_time 加班结束时间
    ,case t1.is_anticipate
        when 0 then '后补'
        when 1 then '预申请'
    end 申请方式
    ,b1.CN_element 加班期间最后一个路由动作
    ,convert_tz(b1.routed_at, '+00:00', '+08:00') 加班期间最后一个路由时间
    ,timestampdiff(second, convert_tz(b1.routed_at, '+00:00', '+08:00'), t1.end_time)/3600 最后一个路由动作距离加班结束时间差_hour
    ,rou.route_num 加班期间路由动作数
-- ho.`type`  as '加班类型
from t t1
left join b b1 on b1.staff_id = t1.staff_id  and b1.start_time = t1.start_time and b1.rk = 1
left join
    (
        select
            b1.staff_id
            ,b1.start_date1
            ,b1.start_time
            ,count(b1.CN_element) route_num
        from b b1
        group by 1,2,3
    ) rou on rou.staff_id = t1.staff_id and rou.start_date1 = t1.start_date1 and rou.start_time = t1.start_time
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
        ,date(ho.start_time) start_date1
    from ph_backyard.hr_overtime ho
    where
        date(ho.start_time) >= '2023-06-01'
        and date(ho.start_time) <= '2023-06-30'
        and ho.state = 2
        and ho.staff_id = '141214'
#         and ho.start_time = '2023-06-30 13:00:00'
)
, b as
(
    select
        t1.*
        ,pr.staff_info_id
        ,ddd.CN_element
        ,pr.routed_at
        ,date(t1.start_time) start_date
        ,row_number() over (partition by pr.staff_info_id, t1.start_time order by pr.routed_at desc) rk
    from ph_staging.parcel_route pr
    join t t1 on t1.staff_id = pr.staff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
    where
        pr.routed_at >= date_sub(t1.start_time, interval 8 hour)
        and pr.routed_at < date_sub(t1.end_time, interval 8 hour)
)

select
    t1.staff_id
    ,hjt.job_name 岗位
    ,case
        when t1.`type` = 1 then '工作日加班1.5倍日薪'
        when t1.`type` = 2 then 'OFF Day加班1.5倍日薪'
        when t1.`type` = 3 then 'Rest Day加班1倍日薪'
        when t1.`type` = 4 then 'Rest Day加班2倍日薪'
        when t1.`type` = 5 then '节假日加班2倍日薪'
        when t1.`type` = 6 then '节假日超时加班3倍日薪'
    end as '加班类型'
    ,t1.start_time 加班开始时间
    ,t1.end_time 加班结束时间
    ,case t1.is_anticipate
        when 0 then '后补'
        when 1 then '预申请'
    end 申请方式
    ,b1.CN_element 加班期间最后一个路由动作
    ,convert_tz(b1.routed_at, '+00:00', '+08:00') 加班期间最后一个路由时间
    ,timestampdiff(second, convert_tz(b1.routed_at, '+00:00', '+08:00'), t1.end_time)/3600 最后一个路由动作距离加班结束时间差_hour
    ,rou.route_num 加班期间路由动作数
-- ho.`type`  as '加班类型
from t t1
left join b b1 on b1.staff_id = t1.staff_id  and b1.start_time = t1.start_time and b1.end_time = t1.end_time and b1.rk = 1
left join
    (
        select
            b1.staff_id
            ,b1.start_date1
            ,b1.start_time
            ,count(b1.CN_element) route_num
        from b b1
        group by 1,2,3
    ) rou on rou.staff_id = t1.staff_id and rou.start_date1 = t1.start_date1 and rou.start_time = t1.start_time
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
        ,date(ho.start_time) start_date1
    from ph_backyard.hr_overtime ho
    where
        date(ho.start_time) >= '2023-06-01'
        and date(ho.start_time) <= '2023-06-30'
        and ho.state = 2
#         and ho.staff_id = '141214'
#         and ho.start_time = '2023-06-30 13:00:00'
)
, b as
(
    select
        t1.*
        ,pr.staff_info_id
        ,ddd.CN_element
        ,pr.routed_at
        ,date(t1.start_time) start_date
        ,row_number() over (partition by pr.staff_info_id, t1.start_time order by pr.routed_at desc) rk
    from ph_staging.parcel_route pr
    join t t1 on t1.staff_id = pr.staff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
    where
        pr.routed_at >= date_sub(t1.start_time, interval 8 hour)
        and pr.routed_at < date_sub(t1.end_time, interval 8 hour)
)

select
    t1.staff_id
    ,hjt.job_name 岗位
    ,case
        when t1.`type` = 1 then '工作日加班1.5倍日薪'
        when t1.`type` = 2 then 'OFF Day加班1.5倍日薪'
        when t1.`type` = 3 then 'Rest Day加班1倍日薪'
        when t1.`type` = 4 then 'Rest Day加班2倍日薪'
        when t1.`type` = 5 then '节假日加班2倍日薪'
        when t1.`type` = 6 then '节假日超时加班3倍日薪'
    end as '加班类型'
    ,t1.start_time 加班开始时间
    ,t1.end_time 加班结束时间
    ,case t1.is_anticipate
        when 0 then '后补'
        when 1 then '预申请'
    end 申请方式
    ,b1.CN_element 加班期间最后一个路由动作
    ,convert_tz(b1.routed_at, '+00:00', '+08:00') 加班期间最后一个路由时间
    ,timestampdiff(second, convert_tz(b1.routed_at, '+00:00', '+08:00'), t1.end_time)/3600 最后一个路由动作距离加班结束时间差_hour
    ,rou.route_num 加班期间路由动作数
-- ho.`type`  as '加班类型
from t t1
left join b b1 on b1.staff_id = t1.staff_id  and b1.start_time = t1.start_time and b1.end_time = t1.end_time and b1.rk = 1
left join
    (
        select
            b1.staff_id
            ,b1.start_date1
            ,b1.start_time
            ,count(b1.CN_element) route_num
        from b b1
        group by 1,2,3
    ) rou on rou.staff_id = t1.staff_id and rou.start_date1 = t1.start_date1 and rou.start_time = t1.start_time
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
        ,date(ho.start_time) start_date1
    from ph_backyard.hr_overtime ho
    where
        date(ho.start_time) >= '2023-06-01'
        and date(ho.start_time) <= '2023-06-30'
        and ho.state = 2
#         and ho.staff_id = '141214'
#         and ho.start_time = '2023-06-30 13:00:00'
)
, b as
(
    select
        t1.*
        ,pr.staff_info_id
        ,ddd.CN_element
        ,pr.routed_at
        ,date(t1.start_time) start_date
        ,row_number() over (partition by pr.staff_info_id, t1.start_time order by pr.routed_at desc) rk
    from ph_staging.parcel_route pr
    join t t1 on t1.staff_id = pr.staff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
    where
        pr.routed_at >= date_sub(t1.start_time, interval 8 hour)
        and pr.routed_at < date_sub(t1.end_time, interval 8 hour)
)

select
    t1.staff_id
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,hjt.job_name 岗位
    ,case
        when t1.`type` = 1 then '工作日加班1.5倍日薪'
        when t1.`type` = 2 then 'OFF Day加班1.5倍日薪'
        when t1.`type` = 3 then 'Rest Day加班1倍日薪'
        when t1.`type` = 4 then 'Rest Day加班2倍日薪'
        when t1.`type` = 5 then '节假日加班2倍日薪'
        when t1.`type` = 6 then '节假日超时加班3倍日薪'
    end as '加班类型'
    ,t1.start_time 加班开始时间
    ,t1.end_time 加班结束时间
    ,case t1.is_anticipate
        when 0 then '后补'
        when 1 then '预申请'
    end 申请方式
    ,b1.CN_element 加班期间最后一个路由动作
    ,convert_tz(b1.routed_at, '+00:00', '+08:00') 加班期间最后一个路由时间
    ,timestampdiff(second, convert_tz(b1.routed_at, '+00:00', '+08:00'), t1.end_time)/3600 最后一个路由动作距离加班结束时间差_hour
    ,rou.route_num 加班期间路由动作数
-- ho.`type`  as '加班类型
from t t1
left join b b1 on b1.staff_id = t1.staff_id  and b1.start_time = t1.start_time and b1.end_time = t1.end_time and b1.rk = 1
left join
    (
        select
            b1.staff_id
            ,b1.start_date1
            ,b1.start_time
            ,count(b1.CN_element) route_num
        from b b1
        group by 1,2,3
    ) rou on rou.staff_id = t1.staff_id and rou.start_date1 = t1.start_date1 and rou.start_time = t1.start_time
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
        ,date(ho.start_time) start_date1
    from ph_backyard.hr_overtime ho
    where
        date(ho.start_time) >= '2023-06-01'
        and date(ho.start_time) <= '2023-06-30'
        and ho.state = 2
#         and ho.staff_id = '141214'
#         and ho.start_time = '2023-06-30 13:00:00'
)
, b as
(
    select
        t1.*
        ,pr.staff_info_id
        ,ddd.CN_element
        ,pr.routed_at
        ,date(t1.start_time) start_date
        ,row_number() over (partition by pr.staff_info_id, t1.start_time order by pr.routed_at desc) rk
    from ph_staging.parcel_route pr
    join t t1 on t1.staff_id = pr.staff_info_id
    left join dwm.dwd_dim_dict ddd on ddd.element = pr.route_action and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_route' and ddd.fieldname = 'route_action'
    where
        pr.routed_at >= date_sub(t1.start_time, interval 8 hour)
        and pr.routed_at < date_sub(t1.end_time, interval 8 hour)
)

select
    t1.staff_id
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,hjt.job_name 岗位
    ,case
        when t1.`type` = 1 then '工作日加班1.5倍日薪'
        when t1.`type` = 2 then 'OFF Day加班1.5倍日薪'
        when t1.`type` = 3 then 'Rest Day加班1倍日薪'
        when t1.`type` = 4 then 'Rest Day加班2倍日薪'
        when t1.`type` = 5 then '节假日加班2倍日薪'
        when t1.`type` = 6 then '节假日超时加班3倍日薪'
    end as '加班类型'
    ,t1.start_time 加班开始时间
    ,t1.end_time 加班结束时间
    ,case t1.is_anticipate
        when 0 then '后补'
        when 1 then '预申请'
    end 申请方式
    ,b1.CN_element 加班期间最后一个路由动作
    ,convert_tz(b1.routed_at, '+00:00', '+08:00') 加班期间最后一个路由时间
    ,timestampdiff(second, convert_tz(b1.routed_at, '+00:00', '+08:00'), t1.end_time)/3600 最后一个路由动作距离加班结束时间差_hour
    ,rou.route_num 加班期间路由动作数
-- ho.`type`  as '加班类型
from t t1
left join b b1 on b1.staff_id = t1.staff_id  and b1.start_time = t1.start_time and b1.end_time = t1.end_time and b1.rk = 1
left join
    (
        select
            b1.staff_id
            ,b1.start_date1
            ,b1.start_time
            ,count(b1.CN_element) route_num
        from b b1
        group by 1,2,3
    ) rou on rou.staff_id = t1.staff_id and rou.start_date1 = t1.start_date1 and rou.start_time = t1.start_time
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = t1.staff_id
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day );
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
        ,pi.dst_store_id
        ,pi.client_id
        ,pi.cod_enabled
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-06-21 16:00:00'
        and pi.state not in (5,7,8,9)
)
select
    t1.pno
    ,if(t1.returned = 1, '退件', '正向件')  方向
    ,t1.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
#     ,case
#         when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
#         when t1.state = 6 and di.pno is null  then '闪速系统沟通处理中'
#         when t1.state != 6 and plt.pno is not null and plt2.pno is not null then '闪速系统沟通处理中'
#         when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
#         when de.last_store_id = t1.ticket_pickup_store_id and plt2.pno is null then '揽件未发出'
#         when t1.dst_store_id = 'PH19040F05' and plt2.pno is null then '弃件未到拍卖仓'
#         when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
#         else null
#     end 卡点原因
#     ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,pr.store_name 最后有效路由动作网点
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
    ,datediff(now(), de.dst_routed_at) 目的地网点停留时间
    ,de.dst_store 目的地网点
    ,de.src_store 揽收网点
    ,de.pickup_time 揽收时间
    ,de.pick_date 揽收日期
    ,if(hold.pno is not null, 'yes', 'no' ) 是否有holding标记
    ,if(pr3.pno is not null, 'yes', 'no') 是否有待退件标记
    ,td.try_num 尝试派送次数
from t t1
left join ph_staging.ka_profile kp on t1.client_id = kp.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
            and pr.organization_type = 1
        ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
left join
    (
        select
            pr2.pno
        from ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.route_action = 'REFUND_CONFIRM'
        group by 1
    ) hold on hold.pno = t1.pno
left join
    (
        select
            pr2.pno
        from  ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.route_action = 'PENDING_RETURN'
        group by 1
    ) pr3 on pr3.pno = t1.pno
left join
    (
        select
            td.pno
            ,count(distinct date(convert_tz(tdm.created_at, '+00:00', '+08:00'))) try_num
        from ph_staging.ticket_delivery td
        join t t1 on t1.pno = td.pno
        left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
        group by 1
    ) td on td.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    month(plt.created_at) p_month
    ,count(if(plt.duty_result = 1, plt.id, null)) 丢失量
    ,count(if(plt.duty_result = 2, plt.id, null)) 破损量
from ph_bi.parcel_lose_task plt
where
    plt.created_at >= '2023-01-01'
    and plt.state = 6
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    month(pct.created_at) p_month
    ,count(pct.id) lp_num
from ph_bi.parcel_claim_task pct
where
    pct.state = 6
    and pct.created_at >= '2023-01-01'
    and pct.created_at < '2023-07-01'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    month(plt.parcel_created_at) p_month
    ,count(if(plt.duty_result = 1, plt.id, null)) 丢失量
    ,count(if(plt.duty_result = 2, plt.id, null)) 破损量
from ph_bi.parcel_lose_task plt
where
    plt.parcel_created_at >= '2023-01-01'
    and plt.state = 6
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    a.p_month
    ,sum(a.claim_money) money_num
from
    (
        select
            a.*
        from
            (
                select
                    month(pct.created_at) p_month
                    ,pct.id
                    ,replace(json_extract(pcn.`neg_result`,'$.money'),'\"','') claim_money
                    ,row_number() over (partition by pcn.`task_id` order by pcn.`created_at` DESC ) rn
                from ph_bi.parcel_claim_task pct
                left join ph_bi.parcel_claim_negotiation pcn on pcn.task_id = pct.id
                where
                    pct.state = 6
                    and pct.created_at >= '2023-01-01'
                    and pct.created_at < '2023-07-01'
            ) a
        where
            a.rn = 1
    ) a
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    *
from ph_bi.parcel_lose_task plt
where
    plt.;
;-- -. . -..- - / . -. - .-. -.--
select
    month(plt.parcel_created_at) p_month
    ,count(plt.id) lp_num
from ph_bi.parcel_lose_task plt
where
    plt.state = 6
    and plt.duty_result = 3
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    month(plt.parcel_created_at) p_month
    ,count(plt.id) lp_num
from ph_bi.parcel_lose_task plt
where
    plt.state = 6
    and plt.duty_result = 3
    and plt.parcel_created_at >= '2023-01-01'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    month(convert_tz(tp.created_at, '+00:00', '+08:00')) p_month
    ,count(distinct tp.id ) 任务数
    ,count(distinct ac.id) 投诉数
    ,count(distinct ac.id)/count(distinct tp.id )
from ph_staging.ticket_pickup tp
left join
    (
        select
            am.merge_column
            ,acc.id
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on acc.abnormal_message_id = am.id
        where
            acc.created_at >= '2023-01-01'
#             and acc.created_at < '2023-07-01'
            and am.relative_type = 2
    ) ac on ac.merge_column = tp.id
where
    tp.created_at >= '2022-12-31 16:00:00'
    and tp.created_at < '2023-06-30 16:00:00'
    and tp.state in (0,1,2,4)
    and tp.channel_category in (1,2,3,4,8,12);
;-- -. . -..- - / . -. - .-. -.--
select
    month(convert_tz(tp.created_at, '+00:00', '+08:00')) p_month
    ,count(distinct tp.id ) 任务数
    ,count(distinct ac.id) 投诉数
    ,count(distinct ac.id)/count(distinct tp.id )
from ph_staging.ticket_pickup tp
left join
    (
        select
            am.merge_column
            ,acc.id
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on acc.abnormal_message_id = am.id
        where
            acc.created_at >= '2023-01-01'
#             and acc.created_at < '2023-07-01'
            and am.relative_type = 2
    ) ac on ac.merge_column = tp.id
where
    tp.created_at >= '2022-12-31 16:00:00'
    and tp.created_at < '2023-06-30 16:00:00'
    and tp.state in (0,1,2,4)
    and tp.channel_category in (1,2,3,4,8,12)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    month(convert_tz(pi.created_at, '+00:00', '+08:00')) p_month
    ,count(distinct pi.pno ) 任务数
    ,count(distinct ac.id) 投诉数
    ,count(distinct ac.id)/count(distinct pi.pno )
from ph_staging.parcel_info pi
left join
    (
        select
            am.merge_column
            ,acc.id
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on acc.abnormal_message_id = am.id
        where
            acc.created_at >= '2023-01-01'
#             and acc.created_at < '2023-07-01'
            and am.relative_type = 1
    )  ac on ac.merge_column = pi.pno
where
    pi.created_at >= '2022-12-31 16:00:00'
    and pi.created_at < '2023-06-30 16:00:00';
;-- -. . -..- - / . -. - .-. -.--
select
    month(convert_tz(pi.created_at, '+00:00', '+08:00')) p_month
    ,count(distinct pi.pno ) 任务数
    ,count(distinct ac.id) 投诉数
    ,count(distinct ac.id)/count(distinct pi.pno )
from ph_staging.parcel_info pi
left join
    (
        select
            am.merge_column
            ,acc.id
        from ph_bi.abnormal_customer_complaint acc
        left join ph_bi.abnormal_message am on acc.abnormal_message_id = am.id
        where
            acc.created_at >= '2023-01-01'
#             and acc.created_at < '2023-07-01'
            and am.relative_type = 1
    )  ac on ac.merge_column = pi.pno
where
    pi.created_at >= '2022-12-31 16:00:00'
    and pi.created_at < '2023-06-30 16:00:00'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
select
    month(mw.created_at ) p_month
    ,count(mw.id)
from ph_backyard.message_warning mw
where
    mw.is_delete = 0
    and mw.created_at >= '2023-01-01';
;-- -. . -..- - / . -. - .-. -.--
select
    month(mw.created_at ) p_month
    ,count(mw.id)
from ph_backyard.message_warning mw
where
    mw.is_delete = 0
    and mw.created_at >= '2023-01-01'
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,hsi3.name submitter_name
    ,hjt2.job_name submitter_job
    ,ra.report_id
    ,concat(tp.cn, tp.eng) reason
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') picture
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join ph_bi.hr_staff_info hsi3 on hsi3.staff_info_id = ra.submitter_id
left join ph_bi.hr_job_title hjt2 on hjt2.id = hsi3.job_title
left join tmpale.tmp_ph_report_reason tp on tp.key = ra.reason
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id and sa.oss_bucket_type = 'REPORT_AUDIT_IMG'
where
    ra.created_at >= '2023-07-10' -- 玺哥不看之前的数据
    and ra.status = 2
    and ra.final_approval_time >= date_sub(curdate(), interval 11 hour)
    and ra.final_approval_time < date_add(curdate(), interval 13 hour )
#     ra.report_id in ('138904','151809')
group by 1
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,a1.id 举报记录ID
    ,a1.submitter_id 举报人工号
    ,a1.submitter_name 举报人姓名
    ,a1.submitter_job 举报人职位
    ,hsi.name 被举报人姓名
    ,date(hsi.hire_date) 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.reason 举报原因
    ,a1.remark 事情描述
    ,a1.picture 图片
    ,hsi.mobile 手机号

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,case
        when smr.name in ('Area3', 'Area6') then '彭万松'
        when smr.name in ('Area4', 'Area9') then '韩钥'
        when smr.name in ('Area7', 'Area8','Area10', 'Area11','FHome') then '张可新'
        when smr.name in ('Area1', 'Area2','Area5', 'Area12') then '李俊'
    end 负责人
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 2;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_0721 t on t.pno = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    a.p_month
    ,a.mw_num
    ,lz.staff_num
    ,a.mw_num - lz.staff_num
from
    (
        select
            month(mw.created_at ) p_month
            ,count(mw.id) mw_num
        from ph_backyard.message_warning mw
        where
            mw.is_delete = 0
            and mw.created_at >= '2023-01-01'
        group by 1
    ) a
left join
    (
        select
            a.leave_month
            ,count(distinct a.staff_info_id) staff_num
        from
            (
                select
                    month(hsi.leave_date) leave_month
                    ,mw.staff_info_id
                    ,count(distinct mw.id) mw_num
                from ph_bi.hr_staff_info hsi
                left join ph_backyard.message_warning mw on mw.staff_info_id = hsi.staff_info_id and mw.is_delete = 0
                where
                    hsi.state = 2
                    and hsi.leave_date >= '2023-01-01'
            ) a
        where
            a.mw_num >= 3
        group by 1
    ) lz on lz.leave_month = a.p_month;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_0721 t on t.运单 = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
from ph_staging.parcel_info pi
left join tmpale.tmp_ph_pno_0721 t on t.运单 = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
select
    t.*
    ,case pi.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
from tmpale.tmp_ph_pno_0721 t
left join ph_staging.parcel_info pi  on t.运单 = pi.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < date_sub(curdate(), interval 2 day)
#                         and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id 工号
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,case
        when hsi2.job_title in (13,110,1000) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end 角色
    ,st.late_num 迟到次数
    ,st.early_num 早退次数
    ,st.absence_sum 缺勤数据
    ,case
        when st.absence_sum = 0 and st.late_num + st.early_num <= 1 and st.late_time_sum + st.early_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3 or st.early_num >= 3 then 'C'
        else 'B'
    end 出勤评级
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
            ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
            ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
                    ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
                    ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < date_sub(curdate(), interval 2 day)
                        and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    ss.store_id 网点ID
    ,dp.store_name 网点
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,ss.num/dp.on_emp_cnt C级员工占比
    ,ss.num C级快递员
    ,dp.on_emp_cnt 在职员工数
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end store_level
from
    (
        select
            s.store_id
            ,count(if(s.ss_level = 'C', s.staff_info_id, null)) num
        from
            (
                select
                    st.staff_info_id
                    ,dp.store_id
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,case
                        when hsi2.job_title in (13,110,1000) then '快递员'
                        when hsi2.job_title in (37) then '仓管员'
                        when hsi2.job_title in (16) then '主管'
                    end roles
                    ,case
                        when st.absence_sum = 0 and st.late_num + st.early_num <= 1 and st.late_time_sum + st.early_time_sum < 30 then 'A'
                        when st.absence_sum >= 2 or st.late_num >= 3 or st.early_num >= 3 then 'C'
                        else 'B'
                    end ss_level
                from
                    (
                        select
                            a.staff_info_id
                            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
                            ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
                            ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                            ,sum(a.absence_time) absence_sum
                        from
                            (
                                select
                                    t1.*
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
                                    ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
                                    ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = ss.store_id and dp.stat_date = '2023-07-18'
where
    dp.on_emp_cnt > 0;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.store_id
        ,pr.pno
        ,pr.staff_info_id
        ,pi.state
    from ph_staging.parcel_route pr
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    where
        pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr.routed_at > date_sub('2023-07-19', interval 8 hour )
    group by 1,2,3
)
select
    dr.store_id 网点ID
    ,dr.store_name 网点
    ,dr.piece_name 片区
    ,dr.region_name 大区
    ,emp_cnt.staf_num 总快递员人数
    ,att.atd_emp_cnt 总出勤快递员人数
    ,a3.sc_num/att.atd_emp_cnt 平均交接量
    ,a3.del_num/att.atd_emp_cnt 平均妥投量
    ,a2.avg_code_scan 三段码平均交接量
    ,a2.avg_code_deli 三段码平均妥投量
    ,a2.avg_code_staff 三段码平均交接快递员数
    ,case
        when a2.avg_code_staff < 1.5 then 'A'
        when a2.avg_code_staff >= 1.5 and a2.avg_code_staff < 2 then 'B'
        when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'C'
        when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'D'
        when a2.avg_code_staff >= 4 then 'E'
    end 评级
from
    (
        select
            a1.store_id
            ,count(distinct a1.pno)/count(distinct a1.third_sorting_code) avg_code_scan
            ,count(distinct if(pi.state = 5, a1.pno, null))/count(distinct a1.third_sorting_code) avg_code_deli
            ,count(distinct a1.staff_info_id)/ count(distinct a1.third_sorting_code) avg_code_staff
        from
            (
                select
                    a1.*
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,ps.third_sorting_code
                            ,row_number() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        left join ph_drds.parcel_sorting_code_info ps on ps.dst_store_id = t1.store_id and ps.pno = t1.pno
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join ph_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
left join
    (
        select
           ad.sys_store_id
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
            and ad.stat_date = '2023-07-19'
       group by 1
    ) att on att.sys_store_id = a2.store_id
left join dwm.dim_ph_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub('2023-07-19', interval 1 day)
left join
    (
        select
            t1.store_id
            ,count(t1.pno) sc_num
            ,count(if(t1.state = 5, t1.pno, null)) del_num
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
#                         and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id 工号
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,case
        when hsi2.job_title in (13,110,1000) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end 角色
    ,st.late_num 迟到次数
    ,st.absence_sum 缺勤数据
    ,case
        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3  then 'C'
        else 'B'
    end 出勤评级
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
#                         and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    ss.store_id 网点ID
    ,dp.store_name 网点
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,ss.num/dp.on_emp_cnt C级员工占比
    ,ss.num C级快递员
    ,dp.on_emp_cnt 在职员工数
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end store_level
from
    (
        select
            s.store_id
            ,count(if(s.ss_level = 'C', s.staff_info_id, null)) num
        from
            (
                select
                    st.staff_info_id
                    ,dp.store_id
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,case
                        when hsi2.job_title in (13,110,1000) then '快递员'
                        when hsi2.job_title in (37) then '仓管员'
                        when hsi2.job_title in (16) then '主管'
                    end roles
                    ,case
                        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
                        when st.absence_sum >= 2 or st.late_num >= 3 then 'C'
                        else 'B'
                    end ss_level
                from
                    (
                        select
                            a.staff_info_id
                            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#                             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#                             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                            ,sum(a.absence_time) absence_sum
                        from
                            (
                                select
                                    t1.*
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = ss.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    dp.on_emp_cnt > 0;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
#                         and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    ss.store_id 网点ID
    ,dp.store_name 网点
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,ss.num/dp.on_emp_cnt C级员工占比
    ,ss.num C级快递员
    ,dp.on_emp_cnt 在职员工数
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end store_level
    ,ss.avg_absence_num 近7天人均缺勤次数
    ,ss.avg_late_num 近7天人均迟到次数
from
    (
        select
            s.store_id
            ,count(if(s.ss_level = 'C', s.staff_info_id, null)) num
            ,sum(s.late_num)/count(distinct s.staff_info_id) avg_late_num
            ,sum(s.absence_sum)/count(distinct s.staff_info_id) avg_absence_num
        from
            (
                select
                    st.staff_info_id
                    ,dp.store_id
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,case
                        when hsi2.job_title in (13,110,1000) then '快递员'
                        when hsi2.job_title in (37) then '仓管员'
                        when hsi2.job_title in (16) then '主管'
                    end roles
                    ,st.late_num
                    ,st.absence_sum
                    ,case
                        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
                        when st.absence_sum >= 2 or st.late_num >= 3 then 'C'
                        else 'B'
                    end ss_level
                from
                    (
                        select
                            a.staff_info_id
                            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#                             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#                             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                            ,sum(a.absence_time) absence_sum
                        from
                            (
                                select
                                    t1.*
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = ss.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    dp.on_emp_cnt > 0;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
#                         and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    ss.store_id 网点ID
    ,dp.store_name 网点
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,ss.num/dp.on_emp_cnt C级员工占比
    ,ss.num C级快递员
    ,dp.on_emp_cnt 在职员工数
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end store_level
    ,ss.avg_absence_num 近7天人均缺勤人数
    ,ss.avg_late_num 近7天人均迟到人数
from
    (
        select
            s.store_id
            ,count(if(s.ss_level = 'C', s.staff_info_id, null)) num
            ,sum(s.late_num)/7 avg_late_num
            ,sum(s.absence_sum)/7 avg_absence_num
        from
            (
                select
                    st.staff_info_id
                    ,dp.store_id
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,case
                        when hsi2.job_title in (13,110,1000) then '快递员'
                        when hsi2.job_title in (37) then '仓管员'
                        when hsi2.job_title in (16) then '主管'
                    end roles
                    ,st.late_num
                    ,st.absence_sum
                    ,case
                        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
                        when st.absence_sum >= 2 or st.late_num >= 3 then 'C'
                        else 'B'
                    end ss_level
                from
                    (
                        select
                            a.staff_info_id
                            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#                             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#                             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                            ,sum(a.absence_time) absence_sum
                        from
                            (
                                select
                                    t1.*
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = ss.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    dp.on_emp_cnt > 0;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.store_id
        ,pr.pno
        ,pr.staff_info_id
        ,pi.state
    from ph_staging.parcel_route pr
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    where
        pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr.routed_at >= date_sub('2023-07-21', interval 8 hour )
        and pr.routed_at < date_add('2023-07-21', interval 16 hour)
    group by 1,2,3
)
select
    dr.store_id 网点ID
    ,dr.store_name 网点
    ,dr.piece_name 片区
    ,dr.region_name 大区
    ,emp_cnt.staf_num 总快递员人数
    ,att.atd_emp_cnt 总出勤快递员人数
    ,a3.sc_num/att.atd_emp_cnt 平均交接量
    ,a3.del_num/att.atd_emp_cnt 平均妥投量
    ,a2.avg_staff_code 三段码平均交接量
    ,a2.avg_staff_del_code 三段码平均妥投量
    ,a2.avg_code_staff 三段码平均交接快递员数
    ,case
        when a2.avg_code_staff < 1.5 then 'A'
        when a2.avg_code_staff >= 1.5 and a2.avg_code_staff < 2 then 'B'
        when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'C'
        when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'D'
        when a2.avg_code_staff >= 4 then 'E'
    end 评级
from
    (
        select
            a1.store_id
            ,count(distinct a1.staff_info_id)/ count(distinct a1.third_sorting_code) avg_code_staff
            ,count(distinct a1.third_sorting_code)/count(distinct a1.staff_info_id)  avg_staff_code
            ,count(distinct if(a1.state = 5, a1.third_sorting_code, null))/count(distinct a1.staff_info_id) avg_staff_del_code
        from
            (
                select
                    a1.*
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,t1.state
                            ,ps.third_sorting_code
                            ,row_number() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        left join ph_drds.parcel_sorting_code_info ps on ps.dst_store_id = t1.store_id and ps.pno = t1.pno
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join ph_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
left join
    (
        select
           ad.sys_store_id
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
            and ad.stat_date = '2023-07-21'
       group by 1
    ) att on att.sys_store_id = a2.store_id
left join dwm.dim_ph_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub('2023-07-21', interval 1 day)
left join
    (
        select
            t1.store_id
            ,count(t1.pno) sc_num
            ,count(if(t1.state = 5, t1.pno, null)) del_num
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    a.p_month
    ,a.mw_num
    ,lz.staff_num
from
    (
        select
            month(mw.created_at ) p_month
            ,count(mw.id) mw_num
        from ph_backyard.message_warning mw
        where
            mw.is_delete = 0
            and mw.created_at >= '2023-01-01'
        group by 1
    ) a
left join
    (
        select
            a.leave_month
            ,count(distinct a.staff_info_id) staff_num
        from
            (
                select
                    month(hsi.leave_date) leave_month
                    ,mw.staff_info_id
                    ,count(distinct mw.id) mw_num
                from ph_bi.hr_staff_info hsi
                left join ph_backyard.message_warning mw on mw.staff_info_id = hsi.staff_info_id and mw.is_delete = 0
                where
                    hsi.state = 2
                    and hsi.leave_date >= '2023-01-01'
            ) a
        where
            a.mw_num >= 3
        group by 1
    ) lz on lz.leave_month = a.p_month;
;-- -. . -..- - / . -. - .-. -.--
select
                    month(hsi.leave_date) leave_month
                    ,mw.staff_info_id
                    ,count(distinct mw.id) mw_num
                from ph_bi.hr_staff_info hsi
                left join ph_backyard.message_warning mw on mw.staff_info_id = hsi.staff_info_id and mw.is_delete = 0
                where
                    hsi.state = 2
                    and hsi.leave_date >= '2023-01-01';
;-- -. . -..- - / . -. - .-. -.--
select
    a.p_month
    ,a.mw_num
    ,lz.staff_num
from
    (
        select
            month(mw.created_at ) p_month
            ,count(mw.id) mw_num
        from ph_backyard.message_warning mw
        where
            mw.is_delete = 0
            and mw.created_at >= '2023-01-01'
        group by 1
    ) a
left join
    (
        select
            a.leave_month
            ,count(distinct a.staff_info_id) staff_num
        from
            (
                select
                    month(hsi.leave_date) leave_month
                    ,mw.staff_info_id
                    ,count(distinct mw.id) mw_num
                from ph_bi.hr_staff_info hsi
                left join ph_backyard.message_warning mw on mw.staff_info_id = hsi.staff_info_id and mw.is_delete = 0
                where
                    hsi.state = 2
                    and hsi.leave_date >= '2023-01-01'
                group by 1,2
            ) a
        where
            a.mw_num >= 3
        group by 1
    ) lz on lz.leave_month = a.p_month;
;-- -. . -..- - / . -. - .-. -.--
select
                    month(hsi.leave_date) leave_month
                    ,mw.staff_info_id
                    ,count(distinct mw.id) mw_num
                from ph_bi.hr_staff_info hsi
                left join ph_backyard.message_warning mw on mw.staff_info_id = hsi.staff_info_id and mw.is_delete = 0
                where
                    hsi.state = 2
                    and hsi.leave_date >= '2023-01-01'
                group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
select
    a.p_month
    ,a.mw_num
    ,lz.staff_num
    ,kc.leave_num - lz.staff_num
from
    (
        select
            month(mw.created_at ) p_month
            ,count(mw.id) mw_num
        from ph_backyard.message_warning mw
        where
            mw.is_delete = 0
            and mw.created_at >= '2023-01-01'
        group by 1
    ) a
left join
    (
        select
            a.leave_month
            ,count(distinct a.staff_info_id) staff_num
        from
            (
                select
                    month(hsi.leave_date) leave_month
                    ,mw.staff_info_id
                    ,count(distinct mw.id) mw_num
                from ph_bi.hr_staff_info hsi
                left join ph_backyard.message_warning mw on mw.staff_info_id = hsi.staff_info_id and mw.is_delete = 0
                where
                    hsi.state = 2
                    and hsi.leave_date >= '2023-01-01'
                    and leave_type != 1
                group by 1,2
            ) a
        where
            a.mw_num >= 3
        group by 1
    ) lz on lz.leave_month = a.p_month
left join
    (
        select
            month(hsi2.leave_date) leave_month
            ,count(distinct hsi2.staff_info_id) leave_num
        from  ph_bi.hr_staff_info hsi2
        where
            hsi2.state = 2
            and hsi2.leave_type not in (1)
            and hsi2.leave_date >= '2023-01-01'
        group by 1
    ) kc on kc.leave_month = a.p_month;
;-- -. . -..- - / . -. - .-. -.--
select
    fvp.pack_no
    ,fvp.relation_no pno
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as customer_type
    ,pi.cod_amount/100 cod
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) cogs
    ,ddd.EN_element parcel_status
from ph_staging.fleet_van_proof_parcel_detail fvp
left join ph_staging.parcel_info pi on pi.pno = fvp.relation_no
left join ph_staging.order_info oi on oi.pno = pi.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join dwm.dwd_dim_dict ddd on ddd.element = pi.state and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_info' and  ddd.fieldname = 'state'
where
    fvp.pack_no in ('P77609536','P77623309','P77617336','P77609527');
;-- -. . -..- - / . -. - .-. -.--
select
    fvp.pack_no
    ,fvp.relation_no pno
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then 'Normal KA'
        when kp.`id` is null then 'GE'
    end as customer_type
    ,pi.cod_amount/100 cod
    ,if(bc.client_name = 'lazada', oi.insure_declare_value/100, oi.cogs_amount/100) cogs
    ,ddd.EN_element parcel_status
from ph_staging.fleet_van_proof_parcel_detail fvp
left join ph_staging.parcel_info pi on pi.pno = fvp.relation_no
left join ph_staging.order_info oi on oi.pno = pi.pno
left join ph_staging.ka_profile kp on kp.id = pi.client_id
left join dwm.dwd_dim_bigClient bc on bc.client_id = pi.client_id
left join dwm.dwd_dim_dict ddd on ddd.element = pi.state and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_info' and  ddd.fieldname = 'state'
where
    fvp.pack_no in ('P77609536','P77623309','P77617336','P77609527');
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
#                         and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    ss.store_id 网点ID
    ,dp.store_name 网点
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,ss.num/dp.on_emp_cnt C级员工占比
    ,ss.num C级快递员
    ,dp.on_emp_cnt 在职员工数
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end store_level
    ,ss.avg_absence_num 近7天人均缺勤人次
    ,ss.avg_late_num 近7天人均迟到人次
from
    (
        select
            s.store_id
            ,count(if(s.ss_level = 'C', s.staff_info_id, null)) num
            ,sum(s.late_num) avg_late_num
            ,sum(s.absence_sum) avg_absence_num
        from
            (
                select
                    st.staff_info_id
                    ,dp.store_id
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,case
                        when hsi2.job_title in (13,110,1000) then '快递员'
                        when hsi2.job_title in (37) then '仓管员'
                        when hsi2.job_title in (16) then '主管'
                    end roles
                    ,st.late_num
                    ,st.absence_sum
                    ,case
                        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
                        when st.absence_sum >= 2 or st.late_num >= 3 then 'C'
                        else 'B'
                    end ss_level
                from
                    (
                        select
                            a.staff_info_id
                            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#                             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#                             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                            ,sum(a.absence_time) absence_sum
                        from
                            (
                                select
                                    t1.*
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = ss.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    dp.on_emp_cnt > 0;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
#                         and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    ss.store_id 网点ID
    ,dp.store_name 网点
    ,dp.store_category
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,ss.num/dp.on_emp_cnt C级员工占比
    ,ss.num C级快递员
    ,dp.on_emp_cnt 在职员工数
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end store_level
    ,ss.avg_absence_num 近7天缺勤人次
    ,ss.avg_absence_num/7 近7天平均每天缺勤人次
    ,ss.avg_late_num 近7天人均迟到人次
    ,ss.avg_late_num/7 近7天平均每天迟到人次
from
    (
        select
            s.store_id
            ,count(if(s.ss_level = 'C', s.staff_info_id, null)) num
            ,sum(s.late_num) avg_late_num
            ,sum(s.absence_sum) avg_absence_num
        from
            (
                select
                    st.staff_info_id
                    ,dp.store_id
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,case
                        when hsi2.job_title in (13,110,1000) then '快递员'
                        when hsi2.job_title in (37) then '仓管员'
                        when hsi2.job_title in (16) then '主管'
                    end roles
                    ,st.late_num
                    ,st.absence_sum
                    ,case
                        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
                        when st.absence_sum >= 2 or st.late_num >= 3 then 'C'
                        else 'B'
                    end ss_level
                from
                    (
                        select
                            a.staff_info_id
                            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#                             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#                             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                            ,sum(a.absence_time) absence_sum
                        from
                            (
                                select
                                    t1.*
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = ss.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    dp.on_emp_cnt > 0;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
#                         and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    ss.store_id 网点ID
    ,dp.store_name 网点
    ,case dp.category
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
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,ss.num/dp.on_emp_cnt C级员工占比
    ,ss.num C级快递员
    ,dp.on_emp_cnt 在职员工数
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end store_level
    ,ss.avg_absence_num 近7天缺勤人次
    ,ss.avg_absence_num/7 近7天平均每天缺勤人次
    ,ss.avg_late_num 近7天人均迟到人次
    ,ss.avg_late_num/7 近7天平均每天迟到人次
from
    (
        select
            s.store_id
            ,count(if(s.ss_level = 'C', s.staff_info_id, null)) num
            ,sum(s.late_num) avg_late_num
            ,sum(s.absence_sum) avg_absence_num
        from
            (
                select
                    st.staff_info_id
                    ,dp.store_id
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,case
                        when hsi2.job_title in (13,110,1000) then '快递员'
                        when hsi2.job_title in (37) then '仓管员'
                        when hsi2.job_title in (16) then '主管'
                    end roles
                    ,st.late_num
                    ,st.absence_sum
                    ,case
                        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
                        when st.absence_sum >= 2 or st.late_num >= 3 then 'C'
                        else 'B'
                    end ss_level
                from
                    (
                        select
                            a.staff_info_id
                            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#                             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#                             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                            ,sum(a.absence_time) absence_sum
                        from
                            (
                                select
                                    t1.*
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = ss.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    dp.on_emp_cnt > 0;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
#                         and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    ss.store_id 网点ID
    ,dp.store_name 网点
    ,case dp.store_category
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
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,ss.num/dp.on_emp_cnt C级员工占比
    ,ss.num C级快递员
    ,dp.on_emp_cnt 在职员工数
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end store_level
    ,ss.avg_absence_num 近7天缺勤人次
    ,ss.avg_absence_num/7 近7天平均每天缺勤人次
    ,ss.avg_late_num 近7天人均迟到人次
    ,ss.avg_late_num/7 近7天平均每天迟到人次
from
    (
        select
            s.store_id
            ,count(if(s.ss_level = 'C', s.staff_info_id, null)) num
            ,sum(s.late_num) avg_late_num
            ,sum(s.absence_sum) avg_absence_num
        from
            (
                select
                    st.staff_info_id
                    ,dp.store_id
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,case
                        when hsi2.job_title in (13,110,1000) then '快递员'
                        when hsi2.job_title in (37) then '仓管员'
                        when hsi2.job_title in (16) then '主管'
                    end roles
                    ,st.late_num
                    ,st.absence_sum
                    ,case
                        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
                        when st.absence_sum >= 2 or st.late_num >= 3 then 'C'
                        else 'B'
                    end ss_level
                from
                    (
                        select
                            a.staff_info_id
                            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#                             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#                             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                            ,sum(a.absence_time) absence_sum
                        from
                            (
                                select
                                    t1.*
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = ss.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    dp.on_emp_cnt > 0;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.store_id
        ,pr.pno
        ,pr.staff_info_id
        ,pi.state
    from ph_staging.parcel_route pr
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    where
        pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr.routed_at >= date_sub('2023-07-22', interval 8 hour )
        and pr.routed_at < date_add('2023-07-22', interval 16 hour)
    group by 1,2,3
)
select
    dr.store_id 网点ID
    ,dr.store_name 网点
    ,dr.piece_name 片区
    ,dr.region_name 大区
    ,emp_cnt.staf_num 总快递员人数
    ,att.atd_emp_cnt 总出勤快递员人数
    ,a3.sc_num/att.atd_emp_cnt 平均交接量
    ,a3.del_num/att.atd_emp_cnt 平均妥投量
    ,a2.avg_staff_code 三段码平均交接量
    ,a2.avg_staff_del_code 三段码平均妥投量
    ,a2.avg_code_staff 三段码平均交接快递员数
    ,case
        when a2.avg_code_staff < 1.5 then 'A'
        when a2.avg_code_staff >= 1.5 and a2.avg_code_staff < 2 then 'B'
        when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'C'
        when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'D'
        when a2.avg_code_staff >= 4 then 'E'
    end 评级
from
    (
        select
            a1.store_id
            ,count(distinct a1.staff_code)/ count(distinct a1.third_sorting_code) avg_code_staff
            ,count(distinct a1.staff_code)/count(distinct a1.staff_info_id)  avg_staff_code
            ,count(distinct if(a1.state = 5, a1.staff_code, null))/count(distinct a1.staff_info_id) avg_staff_del_code
        from
            (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,t1.state
                            ,ps.third_sorting_code
                            ,row_number() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        left join ph_drds.parcel_sorting_code_info ps on ps.dst_store_id = t1.store_id and ps.pno = t1.pno
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join ph_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
left join
    (
        select
           ad.sys_store_id
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
            and ad.stat_date = '2023-07-22'
       group by 1
    ) att on att.sys_store_id = a2.store_id
left join dwm.dim_ph_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub('2023-07-22', interval 1 day)
left join
    (
        select
            t1.store_id
            ,count(t1.pno) sc_num
            ,count(if(t1.state = 5, t1.pno, null)) del_num
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.store_id
        ,pr.pno
        ,pr.staff_info_id
        ,pi.state
    from ph_staging.parcel_route pr
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    where
        pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr.routed_at >= date_sub('2023-07-22', interval 8 hour )
        and pr.routed_at < date_add('2023-07-22', interval 16 hour)
    group by 1,2,3
)
select
    dr.store_id 网点ID
    ,dr.store_name 网点
    ,case dr.store_category
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
    ,dr.piece_name 片区
    ,dr.region_name 大区
    ,emp_cnt.staf_num 总快递员人数
    ,att.atd_emp_cnt 总出勤快递员人数
    ,a3.sc_num/att.atd_emp_cnt 平均交接量
    ,a3.del_num/att.atd_emp_cnt 平均妥投量
    ,a2.avg_staff_code 三段码平均交接量
    ,a2.avg_staff_del_code 三段码平均妥投量
    ,a2.avg_code_staff 三段码平均交接快递员数
    ,case
        when a2.avg_code_staff < 1.5 then 'A'
        when a2.avg_code_staff >= 1.5 and a2.avg_code_staff < 2 then 'B'
        when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'C'
        when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'D'
        when a2.avg_code_staff >= 4 then 'E'
    end 评级
from
    (
        select
            a1.store_id
            ,count(distinct a1.staff_code)/ count(distinct a1.third_sorting_code) avg_code_staff
            ,count(distinct a1.staff_code)/count(distinct a1.staff_info_id)  avg_staff_code
            ,count(distinct if(a1.state = 5, a1.staff_code, null))/count(distinct a1.staff_info_id) avg_staff_del_code
        from
            (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,t1.state
                            ,ps.third_sorting_code
                            ,row_number() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        left join ph_drds.parcel_sorting_code_info ps on ps.dst_store_id = t1.store_id and ps.pno = t1.pno
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join ph_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
left join
    (
        select
           ad.sys_store_id
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
            and ad.stat_date = '2023-07-22'
       group by 1
    ) att on att.sys_store_id = a2.store_id
left join dwm.dim_ph_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub('2023-07-22', interval 1 day)
left join
    (
        select
            t1.store_id
            ,count(t1.pno) sc_num
            ,count(if(t1.state = 5, t1.pno, null)) del_num
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.store_id
        ,pr.pno
        ,pr.staff_info_id
        ,pi.state
    from ph_staging.parcel_route pr
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    where
        pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr.routed_at >= date_sub('2023-07-22', interval 8 hour )
        and pr.routed_at < date_add('2023-07-22', interval 16 hour)
    group by 1,2,3
)
select
    dr.store_id 网点ID
    ,dr.store_name 网点
    ,dr.opening_at 开业时间
    ,case dr.store_category
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
    ,dr.piece_name 片区
    ,dr.region_name 大区
    ,emp_cnt.staf_num 总快递员人数
    ,att.atd_emp_cnt 总出勤快递员人数
    ,a3.sc_num/att.atd_emp_cnt 平均交接量
    ,a3.del_num/att.atd_emp_cnt 平均妥投量
    ,a2.avg_staff_code 三段码平均交接量
    ,a2.avg_staff_del_code 三段码平均妥投量
    ,a2.avg_code_staff 三段码平均交接快递员数
    ,case
        when a2.avg_code_staff < 1.5 then 'A'
        when a2.avg_code_staff >= 1.5 and a2.avg_code_staff < 2 then 'B'
        when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'C'
        when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'D'
        when a2.avg_code_staff >= 4 then 'E'
    end 评级
from
    (
        select
            a1.store_id
            ,count(distinct a1.staff_code)/ count(distinct a1.third_sorting_code) avg_code_staff
            ,count(distinct a1.staff_code)/count(distinct a1.staff_info_id)  avg_staff_code
            ,count(distinct if(a1.state = 5, a1.staff_code, null))/count(distinct a1.staff_info_id) avg_staff_del_code
        from
            (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,t1.state
                            ,ps.third_sorting_code
                            ,row_number() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        left join ph_drds.parcel_sorting_code_info ps on ps.dst_store_id = t1.store_id and ps.pno = t1.pno
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join ph_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
left join
    (
        select
           ad.sys_store_id
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
            and ad.stat_date = '2023-07-22'
       group by 1
    ) att on att.sys_store_id = a2.store_id
left join dwm.dim_ph_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub('2023-07-22', interval 1 day)
left join
    (
        select
            t1.store_id
            ,count(t1.pno) sc_num
            ,count(if(t1.state = 5, t1.pno, null)) del_num
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.store_id
        ,pr.pno
        ,pr.staff_info_id
        ,pi.state
    from ph_staging.parcel_route pr
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    where
        pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr.routed_at >= date_sub('2023-07-22', interval 8 hour )
        and pr.routed_at < date_add('2023-07-22', interval 16 hour)
    group by 1,2,3
)
select
    dr.store_id 网点ID
    ,dr.store_name 网点
    ,dr.opening_at 开业时间
    ,case dr.store_category
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
    ,dr.piece_name 片区
    ,dr.region_name 大区
    ,emp_cnt.staf_num 总快递员人数
    ,att.atd_emp_cnt 总出勤快递员人数
    ,a3.sc_num/att.atd_emp_cnt 平均交接量
    ,a3.del_num/att.atd_emp_cnt 平均妥投量
    ,a2.avg_staff_code 三段码平均交接量
    ,a2.avg_staff_del_code 三段码平均妥投量
    ,a2.avg_code_staff 三段码平均交接快递员数
    ,case
        when a2.avg_code_staff < 1.5 then 'A'
        when a2.avg_code_staff >= 1.5 and a2.avg_code_staff < 2 then 'B'
        when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'C'
        when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'D'
        when a2.avg_code_staff >= 4 then 'E'
    end 评级
    ,a2.code_num
    ,a2.staff_code_num
    ,a2.staff_num
from
    (
        select
            a1.store_id
            ,count(distinct a1.staff_code) staff_code_num
            ,count(distinct a1.third_sorting_code) code_num
            ,count(distinct a1.staff_info_id) staff_num
            ,count(distinct a1.staff_code)/ count(distinct a1.third_sorting_code) avg_code_staff
            ,count(distinct a1.staff_code)/count(distinct a1.staff_info_id)  avg_staff_code
            ,count(distinct if(a1.state = 5, a1.staff_code, null))/count(distinct a1.staff_info_id) avg_staff_del_code
        from
            (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,t1.state
                            ,ps.third_sorting_code
                            ,row_number() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        left join ph_drds.parcel_sorting_code_info ps on ps.dst_store_id = t1.store_id and ps.pno = t1.pno
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join ph_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
left join
    (
        select
           ad.sys_store_id
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
            and ad.stat_date = '2023-07-22'
       group by 1
    ) att on att.sys_store_id = a2.store_id
left join dwm.dim_ph_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub('2023-07-22', interval 1 day)
left join
    (
        select
            t1.store_id
            ,count(t1.pno) sc_num
            ,count(if(t1.state = 5, t1.pno, null)) del_num
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.store_id
        ,pr.pno
        ,pr.staff_info_id
        ,pi.state
    from ph_staging.parcel_route pr
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    where
        pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr.routed_at >= date_sub('2023-07-22', interval 8 hour )
        and pr.routed_at < date_add('2023-07-22', interval 16 hour)
    group by 1,2,3
)
select
    dr.store_id 网点ID
    ,dr.store_name 网点
    ,dr.opening_at 开业时间
    ,case dr.store_category
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
    ,dr.piece_name 片区
    ,dr.region_name 大区
    ,emp_cnt.staf_num 总快递员人数
    ,att.atd_emp_cnt 总出勤快递员人数
    ,a3.sc_num/att.atd_emp_cnt 平均交接量
    ,a3.del_num/att.atd_emp_cnt 平均妥投量
    ,a2.avg_staff_code 三段码平均交接量
    ,a2.avg_staff_del_code 三段码平均妥投量
    ,a2.avg_code_staff 三段码平均交接快递员数
    ,case
        when a2.avg_code_staff < 1.5 then 'A'
        when a2.avg_code_staff >= 1.5 and a2.avg_code_staff < 2 then 'B'
        when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'C'
        when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'D'
        when a2.avg_code_staff >= 4 then 'E'
    end 评级
    ,a2.code_num
    ,a2.staff_code_num
    ,a2.staff_num
    ,a2.fin_staff_code_num
from
    (
        select
            a1.store_id
            ,count(distinct a1.staff_code) staff_code_num
            ,count(distinct a1.third_sorting_code) code_num
            ,count(distinct a1.staff_info_id) staff_num
            ,count(distinct if(a1.state = 5, a1.staff_code, null)) fin_staff_code_num
            ,count(distinct a1.staff_code)/ count(distinct a1.third_sorting_code) avg_code_staff
            ,count(distinct a1.staff_code)/count(distinct a1.staff_info_id)  avg_staff_code
            ,count(distinct if(a1.state = 5, a1.staff_code, null))/count(distinct a1.staff_info_id) avg_staff_del_code
        from
            (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,t1.state
                            ,ps.third_sorting_code
                            ,row_number() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        left join ph_drds.parcel_sorting_code_info ps on ps.dst_store_id = t1.store_id and ps.pno = t1.pno
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join ph_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
left join
    (
        select
           ad.sys_store_id
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
            and ad.stat_date = '2023-07-22'
       group by 1
    ) att on att.sys_store_id = a2.store_id
left join dwm.dim_ph_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub('2023-07-22', interval 1 day)
left join
    (
        select
            t1.store_id
            ,count(t1.pno) sc_num
            ,count(if(t1.state = 5, t1.pno, null)) del_num
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
#                         and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    ss.store_id 网点ID
    ,dp.store_name 网点
    ,case dp.store_category
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
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,ss.num/dp.on_emp_cnt C级员工占比
    ,ss.num C级快递员
    ,dp.on_emp_cnt 在职员工数
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end store_level
    ,ss.avg_absence_num 近7天缺勤人次
    ,ss.avg_absence_num/7 近7天平均每天缺勤人次
    ,ss.avg_late_num 近7天人均迟到人次
    ,ss.avg_late_num/7 近7天平均每天迟到人次
from
    (
        select
            s.store_id
            ,count(if(s.ss_level = 'C', s.staff_info_id, null)) num
            ,sum(s.late_num) avg_late_num
            ,sum(s.absence_sum) avg_absence_num
        from
            (
                select
                    st.staff_info_id
                    ,dp.store_id
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,case
                        when hsi2.job_title in (13,110,1000) then '快递员'
                        when hsi2.job_title in (37) then '仓管员'
                        when hsi2.job_title in (16) then '主管'
                    end roles
                    ,st.late_num
                    ,st.absence_sum
                    ,case
                        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
                        when st.absence_sum >= 2 or st.late_num >= 3 then 'C'
                        else 'B'
                    end ss_level
                from
                    (
                        select
                            a.staff_info_id
                            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#                             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#                             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                            ,sum(a.absence_time) absence_sum
                        from
                            (
                                select
                                    t1.*
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = ss.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    dp.on_emp_cnt > 0
    and dp.store_category = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
#                         and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    ss.store_id 网点ID
    ,dp.store_name 网点
    ,dp.opening_at 开业时间
    ,case dp.store_category
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
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,ss.num/dp.on_emp_cnt C级员工占比
    ,ss.num C级快递员
    ,dp.on_emp_cnt 在职员工数
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end store_level
    ,ss.avg_absence_num 近7天缺勤人次
    ,ss.avg_absence_num/7 近7天平均每天缺勤人次
    ,ss.avg_late_num 近7天人均迟到人次
    ,ss.avg_late_num/7 近7天平均每天迟到人次
from
    (
        select
            s.store_id
            ,count(if(s.ss_level = 'C', s.staff_info_id, null)) num
            ,sum(s.late_num) avg_late_num
            ,sum(s.absence_sum) avg_absence_num
        from
            (
                select
                    st.staff_info_id
                    ,dp.store_id
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,case
                        when hsi2.job_title in (13,110,1000) then '快递员'
                        when hsi2.job_title in (37) then '仓管员'
                        when hsi2.job_title in (16) then '主管'
                    end roles
                    ,st.late_num
                    ,st.absence_sum
                    ,case
                        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
                        when st.absence_sum >= 2 or st.late_num >= 3 then 'C'
                        else 'B'
                    end ss_level
                from
                    (
                        select
                            a.staff_info_id
                            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#                             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#                             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                            ,sum(a.absence_time) absence_sum
                        from
                            (
                                select
                                    t1.*
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = ss.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    dp.on_emp_cnt > 0
    and dp.store_category = 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    a.大区
    ,a.片区
    ,count(distinct a.工号) 近7天出勤人数
    ,count(distinct if(a.迟到次数 > 0, a.工号, null)) 近7天有过迟到人数
    ,count(distinct if(a.缺勤数据 > 0, a.工号, null)) 近7天有过缺勤人数
    ,count(distinct if(a.缺勤数据 > 0 and a.迟到次数 > 0, a.工号, null)) 近7天同时有过迟到和缺勤人数
from
    (
        select
            st.staff_info_id 工号
            ,dp.store_name 网点
            ,dp.piece_name 片区
            ,dp.region_name 大区
            ,case
                when hsi2.job_title in (13,110,1000) then '快递员'
                when hsi2.job_title in (37) then '仓管员'
                when hsi2.job_title in (16) then '主管'
            end 角色
            ,st.late_num 迟到次数
            ,st.absence_sum 缺勤数据
            ,case
                when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
                when st.absence_sum >= 2 or st.late_num >= 3  then 'C'
                else 'B'
            end 出勤评级
        from
            (
                select
                    a.staff_info_id
                    ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
        #             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                    ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
        #             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                    ,sum(a.absence_time) absence_sum
                from
                    (
                        select
                            t1.*
                            ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                            ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
        #                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
        #                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                            ,t1.AB/10 absence_time
                        from t t1
                    ) a
                group by 1
            ) st
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
        left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
        order by 2,1
    ) a
group by 1,2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)

select

    dp.region_name 大区
    ,count(if(hsi2.job_title in (13,110,1000), st.staff_info_id, null)) 出勤人次_快递员
    ,count(if(hsi2.job_title in (13,110,1000) and st.late_or_not = 'y', st.staff_info_id, null)) 迟到人次_快递员
    ,count(if(hsi2.job_title in (13,110,1000) and st.absence_time > 0, st.staff_info_id, null)) 缺勤人次_快递员
    ,count(if(hsi2.job_title in (13,110,1000) and st.late_or_not = 'y', st.staff_info_id, null))/count(if(hsi2.job_title in (13,110,1000), st.staff_info_id, null)) 迟到占比_快递员
    ,count(if(hsi2.job_title in (13,110,1000) and st.absence_time > 0, st.staff_info_id, null))/count(if(hsi2.job_title in (13,110,1000), st.staff_info_id, null)) 缺勤占比_快递员

    ,count(if(hsi2.job_title in (37), st.staff_info_id, null)) 出勤人次_仓管
    ,count(if(hsi2.job_title in (37) and st.late_or_not = 'y', st.staff_info_id, null)) 迟到人次_仓管
    ,count(if(hsi2.job_title in (37) and st.absence_time > 0, st.staff_info_id, null)) 缺勤人次_仓管
    ,count(if(hsi2.job_title in (37) and st.late_or_not = 'y', st.staff_info_id, null))/count(if(hsi2.job_title in (13,110,1000), st.staff_info_id, null)) 迟到占比_仓管
    ,count(if(hsi2.job_title in (37) and st.absence_time > 0, st.staff_info_id, null))/count(if(hsi2.job_title in (13,110,1000), st.staff_info_id, null)) 缺勤占比_仓管

    ,count(if(hsi2.job_title in (16), st.staff_info_id, null)) 出勤人次_主管
    ,count(if(hsi2.job_title in (16) and st.late_or_not = 'y', st.staff_info_id, null)) 迟到人次_主管
    ,count(if(hsi2.job_title in (16) and st.absence_time > 0, st.staff_info_id, null)) 缺勤人次_主管
    ,count(if(hsi2.job_title in (16) and st.late_or_not = 'y', st.staff_info_id, null))/count(if(hsi2.job_title in (13,110,1000), st.staff_info_id, null)) 迟到占比_主管
    ,count(if(hsi2.job_title in (16) and st.absence_time > 0, st.staff_info_id, null))/count(if(hsi2.job_title in (13,110,1000), st.staff_info_id, null)) 缺勤占比_主管
from
    (
        select
            a.*
        from
            (
                select
                    t1.*
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                    ,t1.AB/10 absence_time
                from t t1
            ) a
    ) st
left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
group by 1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)

select

    dp.region_name 大区
    ,count(if(hsi2.job_title in (13,110,1000), st.staff_info_id, null)) 出勤人次_快递员
    ,count(if(hsi2.job_title in (13,110,1000) and st.late_or_not = 'y', st.staff_info_id, null)) 迟到人次_快递员
    ,count(if(hsi2.job_title in (13,110,1000) and st.absence_time > 0, st.staff_info_id, null)) 缺勤人次_快递员
    ,count(if(hsi2.job_title in (13,110,1000) and st.late_or_not = 'y', st.staff_info_id, null))/count(if(hsi2.job_title in (13,110,1000), st.staff_info_id, null)) 迟到占比_快递员
    ,count(if(hsi2.job_title in (13,110,1000) and st.absence_time > 0, st.staff_info_id, null))/count(if(hsi2.job_title in (13,110,1000), st.staff_info_id, null)) 缺勤占比_快递员

    ,count(if(hsi2.job_title in (37), st.staff_info_id, null)) 出勤人次_仓管
    ,count(if(hsi2.job_title in (37) and st.late_or_not = 'y', st.staff_info_id, null)) 迟到人次_仓管
    ,count(if(hsi2.job_title in (37) and st.absence_time > 0, st.staff_info_id, null)) 缺勤人次_仓管
    ,count(if(hsi2.job_title in (37) and st.late_or_not = 'y', st.staff_info_id, null))/count(if(hsi2.job_title in (13,110,1000), st.staff_info_id, null)) 迟到占比_仓管
    ,count(if(hsi2.job_title in (37) and st.absence_time > 0, st.staff_info_id, null))/count(if(hsi2.job_title in (13,110,1000), st.staff_info_id, null)) 缺勤占比_仓管

    ,count(if(hsi2.job_title in (16), st.staff_info_id, null)) 出勤人次_主管
    ,count(if(hsi2.job_title in (16) and st.late_or_not = 'y', st.staff_info_id, null)) 迟到人次_主管
    ,count(if(hsi2.job_title in (16) and st.absence_time > 0, st.staff_info_id, null)) 缺勤人次_主管
    ,count(if(hsi2.job_title in (16) and st.late_or_not = 'y', st.staff_info_id, null))/count(if(hsi2.job_title in (13,110,1000), st.staff_info_id, null)) 迟到占比_主管
    ,count(if(hsi2.job_title in (16) and st.absence_time > 0, st.staff_info_id, null))/count(if(hsi2.job_title in (13,110,1000), st.staff_info_id, null)) 缺勤占比_主管
from
    (
        select
            a.*
        from
            (
                select
                    t1.*
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                    ,t1.AB/10 absence_time
                from t t1
            ) a
    ) st
left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
group by 1
with rollup;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.store_id
        ,pr.pno
        ,pr.staff_info_id
        ,pi.state
    from ph_staging.parcel_route pr
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    where
        pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr.routed_at >= date_sub('2023-07-22', interval 8 hour )
        and pr.routed_at < date_add('2023-07-22', interval 16 hour)
    group by 1,2,3
)
select
    dr.store_id 网点ID
    ,dr.store_name 网点
    ,dr.opening_at 开业时间
    ,case dr.store_category
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
    ,dr.piece_name 片区
    ,dr.region_name 大区
    ,emp_cnt.staf_num 总快递员人数
    ,att.atd_emp_cnt 总出勤快递员人数
    ,a3.sc_num/att.atd_emp_cnt 平均交接量
    ,a3.del_num/att.atd_emp_cnt 平均妥投量
    ,a2.avg_staff_code 三段码平均交接量
    ,a2.avg_staff_del_code 三段码平均妥投量
    ,a2.avg_code_staff 三段码平均交接快递员数
    ,case
        when a2.avg_code_staff < 2 then 'A'
        when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'B'
        when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'C'
        when a2.avg_code_staff >= 4 then 'D'
    end 评级
    ,a2.code_num
    ,a2.staff_code_num
    ,a2.staff_num
    ,a2.fin_staff_code_num
from
    (
        select
            a1.store_id
            ,count(distinct a1.staff_code) staff_code_num
            ,count(distinct a1.third_sorting_code) code_num
            ,count(distinct a1.staff_info_id) staff_num
            ,count(distinct if(a1.state = 5, a1.staff_code, null)) fin_staff_code_num
            ,count(distinct a1.staff_code)/ count(distinct a1.third_sorting_code) avg_code_staff
            ,count(distinct a1.staff_code)/count(distinct a1.staff_info_id)  avg_staff_code
            ,count(distinct if(a1.state = 5, a1.staff_code, null))/count(distinct a1.staff_info_id) avg_staff_del_code
        from
            (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,t1.state
                            ,ps.third_sorting_code
                            ,row_number() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        left join ph_drds.parcel_sorting_code_info ps on ps.dst_store_id = t1.store_id and ps.pno = t1.pno
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join ph_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
left join
    (
        select
           ad.sys_store_id
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
            and ad.stat_date = '2023-07-22'
       group by 1
    ) att on att.sys_store_id = a2.store_id
left join dwm.dim_ph_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub('2023-07-22', interval 1 day)
left join
    (
        select
            t1.store_id
            ,count(t1.pno) sc_num
            ,count(if(t1.state = 5, t1.pno, null)) del_num
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        swm.staff_info_id
        ,swm.date_at
        ,hsi.sys_store_id
        ,swm.data_bucket
    from ph_backyard.staff_warning_message swm
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = swm.staff_info_id
    where
        swm.hr_fix_status != 0
        and data_fix_status = 0
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.staff_info_id
            from a a1
            group by 1
        )a1 on a1.staff_info_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,hsi.name 姓名
    ,date(hsi.hire_date) 入职日期
    ,hjt.job_name 岗位
    ,a1.date_at 违规日期
    ,hsi.mobile 手机号
    ,json_extract(a1.data_bucket, '$.false_type') 违规类型
    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,case
        when smr.name in ('Area3', 'Area6') then '彭万松'
        when smr.name in ('Area4', 'Area9') then '韩钥'
        when smr.name in ('Area7', 'Area8','Area10', 'Area11','FHome') then '张可新'
        when smr.name in ('Area1', 'Area2','Area5', 'Area12') then '李俊'
    end 负责人
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.staff_info_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.staff_info_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.staff_info_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.staff_info_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.date_at
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.staff_info_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.date_at, interval 8 hour)
            and pr.routed_at < date_add(a1.date_at, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.staff_info_id and sc.date_at = a1.date_at
left join
    (
        select
            pr.staff_info_id
            ,a1.date_at
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.staff_info_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.date_at, interval 8 hour)
            and pr.routed_at < date_add(a1.date_at, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.staff_info_id and del.date_at = a1.date_at
left join
    (
        select
            pr.staff_info_id
            ,a1.date_at
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.staff_info_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.date_at, interval 8 hour)
            and pr.routed_at < date_add(a1.date_at, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.staff_info_id and pick.date_at = a1.date_at
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.date_at
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.date_at
                from a a1
                group by 1
            )  a1 on a1.date_at = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.date_at = a1.date_at and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.date_at
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.date_at
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.date_at = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.date_at = a1.date_at
left join
    (
        select
            a1.sys_store_id
            ,a1.date_at
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.date_at
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.date_at, interval 8 hour)
            and pi.finished_at < date_add(a1.date_at, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.date_at = a1.date_at
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id
group by 2;
;-- -. . -..- - / . -. - .-. -.--
select
        swm.staff_info_id
        ,swm.date_at
        ,hsi.sys_store_id
        ,swm.data_bucket
    from ph_backyard.staff_warning_message swm
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = swm.staff_info_id
    where
        swm.hr_fix_status != 0
        and data_fix_status = 0;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        swm.staff_info_id
        ,swm.date_at
        ,hsi.sys_store_id
        ,swm.data_bucket
    from ph_backyard.staff_warning_message swm
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = swm.staff_info_id
    where
        swm.hr_fix_status != 0
        and data_fix_status = 0
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.staff_info_id
            from a a1
            group by 1
        )a1 on a1.staff_info_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,hsi.name 姓名
    ,date(hsi.hire_date) 入职日期
    ,hjt.job_name 岗位
    ,a1.date_at 违规日期
    ,hsi.mobile 手机号
    ,json_extract(a1.data_bucket, '$.false_type') 违规类型
    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,case
        when smr.name in ('Area3', 'Area6') then '彭万松'
        when smr.name in ('Area4', 'Area9') then '韩钥'
        when smr.name in ('Area7', 'Area8','Area10', 'Area11','FHome') then '张可新'
        when smr.name in ('Area1', 'Area2','Area5', 'Area12') then '李俊'
    end 负责人
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.staff_info_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.staff_info_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.staff_info_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.staff_info_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.date_at
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.staff_info_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.date_at, interval 8 hour)
            and pr.routed_at < date_add(a1.date_at, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.staff_info_id and sc.date_at = a1.date_at
left join
    (
        select
            pr.staff_info_id
            ,a1.date_at
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.staff_info_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.date_at, interval 8 hour)
            and pr.routed_at < date_add(a1.date_at, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on sc.staff_info_id = a1.staff_info_id and del.date_at = a1.date_at
left join
    (
        select
            pr.staff_info_id
            ,a1.date_at
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.staff_info_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.date_at, interval 8 hour)
            and pr.routed_at < date_add(a1.date_at, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.staff_info_id and pick.date_at = a1.date_at
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.date_at
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.date_at
                from a a1
                group by 1
            )  a1 on a1.date_at = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.date_at = a1.date_at and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.date_at
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.date_at
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.date_at = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.date_at = a1.date_at
left join
    (
        select
            a1.sys_store_id
            ,a1.date_at
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.date_at
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.date_at, interval 8 hour)
            and pi.finished_at < date_add(a1.date_at, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.date_at = a1.date_at
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        swm.staff_info_id
        ,swm.date_at
        ,hsi.sys_store_id
        ,swm.data_bucket
    from ph_backyard.staff_warning_message swm
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = swm.staff_info_id
    where
        swm.hr_fix_status != 0
        and data_fix_status = 0
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.staff_info_id
            from a a1
            group by 1
        )a1 on a1.staff_info_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,hsi.name 姓名
    ,date(hsi.hire_date) 入职日期
    ,hjt.job_name 岗位
    ,a1.date_at 违规日期
    ,hsi.mobile 手机号
    ,json_extract(a1.data_bucket, '$.false_type') 违规类型
    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,case
        when smr.name in ('Area3', 'Area6') then '彭万松'
        when smr.name in ('Area4', 'Area9') then '韩钥'
        when smr.name in ('Area7', 'Area8','Area10', 'Area11','FHome') then '张可新'
        when smr.name in ('Area1', 'Area2','Area5', 'Area12') then '李俊'
    end 负责人
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.staff_info_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.staff_info_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.staff_info_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.staff_info_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.date_at
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.staff_info_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.date_at, interval 8 hour)
            and pr.routed_at < date_add(a1.date_at, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1,2
    ) sc on sc.staff_info_id = a1.staff_info_id and sc.date_at = a1.date_at
left join
    (
        select
            pr.staff_info_id
            ,a1.date_at
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.staff_info_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.date_at, interval 8 hour)
            and pr.routed_at < date_add(a1.date_at, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1,2
    ) del on sc.staff_info_id = a1.staff_info_id and del.date_at = a1.date_at
left join
    (
        select
            pr.staff_info_id
            ,a1.date_at
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.staff_info_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.date_at, interval 8 hour)
            and pr.routed_at < date_add(a1.date_at, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.staff_info_id and pick.date_at = a1.date_at
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.date_at
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.date_at
                from a a1
                group by 1
            )  a1 on a1.date_at = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.date_at = a1.date_at and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.date_at
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.date_at
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.date_at = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.date_at = a1.date_at
left join
    (
        select
            a1.sys_store_id
            ,a1.date_at
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.date_at
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.date_at, interval 8 hour)
            and pi.finished_at < date_add(a1.date_at, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.date_at = a1.date_at
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        swm.staff_info_id
        ,swm.date_at
        ,hsi.sys_store_id
        ,swm.data_bucket
    from ph_backyard.staff_warning_message swm
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = swm.staff_info_id
    where
        swm.hr_fix_status != 0
        and data_fix_status = 0
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.staff_info_id
            from a a1
            group by 1
        )a1 on a1.staff_info_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,hsi.name 姓名
    ,date(hsi.hire_date) 入职日期
    ,hjt.job_name 岗位
    ,a1.date_at 违规日期
    ,hsi.mobile 手机号
    ,json_extract(a1.data_bucket, '$.false_type') 违规类型
    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,case
        when smr.name in ('Area3', 'Area6') then '彭万松'
        when smr.name in ('Area4', 'Area9') then '韩钥'
        when smr.name in ('Area7', 'Area8','Area10', 'Area11','FHome') then '张可新'
        when smr.name in ('Area1', 'Area2','Area5', 'Area12') then '李俊'
    end 负责人
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.staff_info_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.staff_info_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.staff_info_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.staff_info_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.date_at
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.staff_info_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.date_at, interval 8 hour)
            and pr.routed_at < date_add(a1.date_at, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1,2
    ) sc on sc.staff_info_id = a1.staff_info_id and sc.date_at = a1.date_at
left join
    (
        select
            pr.staff_info_id
            ,a1.date_at
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.staff_info_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.date_at, interval 8 hour)
            and pr.routed_at < date_add(a1.date_at, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1,2
    ) del on del.staff_info_id = a1.staff_info_id and del.date_at = a1.date_at
left join
    (
        select
            pr.staff_info_id
            ,a1.date_at
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.staff_info_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.date_at, interval 8 hour)
            and pr.routed_at < date_add(a1.date_at, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.staff_info_id and pick.date_at = a1.date_at
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.date_at
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.date_at
                from a a1
                group by 1
            )  a1 on a1.date_at = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.date_at = a1.date_at and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.date_at
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.date_at
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.date_at = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.date_at = a1.date_at
left join
    (
        select
            a1.sys_store_id
            ,a1.date_at
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.date_at
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.date_at, interval 8 hour)
            and pi.finished_at < date_add(a1.date_at, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.date_at = a1.date_at
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
    select
        swm.staff_info_id
        ,swm.date_at
        ,hsi.sys_store_id
        ,swm.data_bucket
    from ph_backyard.staff_warning_message swm
    left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = swm.staff_info_id
    where
        swm.hr_fix_status != 0
        and data_fix_status = 0
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.staff_info_id
            from a a1
            group by 1
        )a1 on a1.staff_info_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,hsi.name 姓名
    ,date(hsi.hire_date) 入职日期
    ,hjt.job_name 岗位
    ,a1.date_at 违规日期
    ,hsi.mobile 手机号
    ,json_extract(a1.data_bucket, '$.false_type') 违规类型
    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,case
        when smr.name in ('Area3', 'Area6') then '彭万松'
        when smr.name in ('Area4', 'Area9') then '韩钥'
        when smr.name in ('Area7','Area10', 'Area11','FHome') then '张可新'
        when smr.name in ('Area8') then '黄勇'
        when smr.name in ('Area1', 'Area2','Area5', 'Area12') then '李俊'
    end 负责人
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.staff_info_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.staff_info_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.staff_info_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.staff_info_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.date_at
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.staff_info_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.date_at, interval 8 hour)
            and pr.routed_at < date_add(a1.date_at, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1,2
    ) sc on sc.staff_info_id = a1.staff_info_id and sc.date_at = a1.date_at
left join
    (
        select
            pr.staff_info_id
            ,a1.date_at
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.staff_info_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.date_at, interval 8 hour)
            and pr.routed_at < date_add(a1.date_at, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1,2
    ) del on del.staff_info_id = a1.staff_info_id and del.date_at = a1.date_at
left join
    (
        select
            pr.staff_info_id
            ,a1.date_at
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.staff_info_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.date_at, interval 8 hour)
            and pr.routed_at < date_add(a1.date_at, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.staff_info_id and pick.date_at = a1.date_at
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.date_at
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.date_at
                from a a1
                group by 1
            )  a1 on a1.date_at = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.date_at = a1.date_at and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.date_at
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.date_at
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.date_at = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.date_at = a1.date_at
left join
    (
        select
            a1.sys_store_id
            ,a1.date_at
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.date_at
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.date_at, interval 8 hour)
            and pi.finished_at < date_add(a1.date_at, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.date_at = a1.date_at
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id;
;-- -. . -..- - / . -. - .-. -.--
with a as
(
select
    ra.id
    ,ra.submitter_id
    ,hsi3.name submitter_name
    ,hjt2.job_name submitter_job
    ,ra.report_id
    ,concat(tp.cn, tp.eng) reason
    ,hsi.sys_store_id
    ,ra.event_date
    ,ra.remark
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') picture
from ph_backyard.report_audit ra
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ra.report_id
left join ph_bi.hr_staff_info hsi3 on hsi3.staff_info_id = ra.submitter_id
left join ph_bi.hr_job_title hjt2 on hjt2.id = hsi3.job_title
left join tmpale.tmp_ph_report_reason tp on tp.key = ra.reason
left join ph_backyard.sys_attachment sa on sa.oss_bucket_key = ra.id and sa.oss_bucket_type = 'REPORT_AUDIT_IMG'
where
    ra.created_at >= '2023-07-10' -- QC不看之前的数据
    and ra.status = 2
    and ra.final_approval_time >= date_sub(curdate(), interval 11 hour)
    and ra.final_approval_time < date_add(curdate(), interval 13 hour )
group by 1
)
, mw as
(
    select
        mw.staff_info_id
        ,mw.id
        ,mw.created_at
        ,row_number() over (partition by mw.staff_info_id order by mw.created_at) rk
        ,count(id) over (partition by mw.staff_info_id) warn_num
    from ph_backyard.message_warning mw
    join
        (
            select
                a1.report_id
            from a a1
            group by 1
        )a1 on a1.report_id = mw.staff_info_id
    where
        mw.is_delete = 0
)
select
    hsi.staff_info_id 工号
    ,a1.id 举报记录ID
    ,a1.submitter_id 举报人工号
    ,a1.submitter_name 举报人姓名
    ,a1.submitter_job 举报人职位
    ,hsi.name 被举报人姓名
    ,date(hsi.hire_date) 入职日期
    ,hjt.job_name 岗位
    ,a1.event_date 违规日期
    ,a1.reason 举报原因
    ,a1.remark 事情描述
    ,a1.picture 图片
    ,hsi.mobile 手机号

    ,sc.num 员工当日交接量
    ,del.num 员工当日妥投量
    ,pick.num 员工当日揽件量
    ,mw1.warn_num 历史警告信次数
    ,mw1.created_at 第一次警告信时间
    ,mw2.created_at 第二次警告信时间
    ,mw3.created_at 第三次警告信时间

    ,ss2.name 网点
    ,smp.name 片区
    ,smr.name 大区
    ,case
        when smr.name in ('Area3', 'Area6') then '彭万松'
        when smr.name in ('Area4', 'Area9') then '韩钥'
        when smr.name in ('Area7', 'Area8','Area10', 'Area11','FHome') then '张可新'
        when smr.name in ('Area1', 'Area2','Area5', 'Area12') then '李俊'
    end 负责人
    ,emp_cnt.staf_num 现有快递员数
    ,shl_del.sh_del_num 网点当日应派件量
    ,shl_del.delivery_rate 当日妥投率
    ,att.atd_emp_cnt 网点当日出勤人数_快递员
    ,fin.fin_pno 网点当日妥投量
    ,last30.warn_num 过去30天警告信数量
    ,last30.warn_staff_num 过去30天警告信人数
    ,last7.warn_num 过去7天警告信数量
    ,last7.warn_staff_num 过去7天警告信人数
    ,coalesce(concat(round(last_month.当月离职人数*100/last_month.当月总人数 ,2), '%') ,0) 上月离职率
from ph_bi.hr_staff_info hsi
join a a1 on a1.report_id = hsi.staff_info_id
left join ph_staging.sys_store ss2 on ss2.id = hsi.sys_store_id
left join ph_staging.sys_manage_piece smp on smp.id = ss2.manage_piece
left join ph_staging.sys_manage_region smr on smr.id = ss2.manage_region
left join ph_bi.hr_job_title hjt on hjt.id = hsi.job_title
left join mw mw1 on mw1.staff_info_id = a1.report_id and mw1.rk = 1
left join mw mw2 on mw2.staff_info_id = a1.report_id and mw2.rk = 2
left join mw mw3 on mw3.staff_info_id = a1.report_id and mw3.rk = 3
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        group by 1
    ) sc on sc.staff_info_id = a1.report_id and sc.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'DELIVERY_CONFIRM'
        group by 1
    ) del on del.staff_info_id = a1.report_id and del.event_date = a1.event_date
left join
    (
        select
            pr.staff_info_id
            ,a1.event_date
            ,count(distinct pr.pno) num
        from ph_staging.parcel_route pr
        join a a1 on a1.report_id = pr.staff_info_id
        where
            pr.routed_at >= date_sub(a1.event_date, interval 8 hour)
            and pr.routed_at < date_add(a1.event_date, interval 16 hour)
            and pr.route_action = 'RECEIVED'
        group by 1
    ) pick on pick.staff_info_id = a1.report_id and pick.event_date = a1.event_date
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        join a a1 on a1.sys_store_id = hr.sys_store_id
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a1.sys_store_id
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct dc.pno) sh_del_num
            ,count(distinct if(pi2.state = 5, dc.pno, null)) sh_del_del_num
            ,concat(round(count(distinct if(pi2.state = 5, dc.pno, null))*100/count(distinct dc.pno) ,2) ,'%') delivery_rate
        from ph_bi.dc_should_delivery_today  dc
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            )  a1 on a1.event_date = dc.stat_date and a1.sys_store_id = dc.store_id
        left join ph_staging.parcel_info pi2 on pi2.pno = dc.pno
        group by 1,2
    ) shl_del on shl_del.event_date = a1.event_date and shl_del.sys_store_id = a1.sys_store_id
left join
    (
        select
           ad.sys_store_id
           ,a1.event_date
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = ad.sys_store_id and a1.event_date = ad.stat_date
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
       group by 1,2
    ) att on att.sys_store_id = a1.sys_store_id and att.event_date = a1.event_date
left join
    (
        select
            a1.sys_store_id
            ,a1.event_date
            ,count(distinct pi.pno) fin_pno
        from ph_staging.parcel_info pi
        join
            (
                select
                    a1.sys_store_id
                    ,a1.event_date
                from a a1
                group by 1
            ) a1 on a1.sys_store_id = pi.ticket_delivery_store_id
        where
            pi.state = 5
            and pi.finished_at >= date_sub(a1.event_date, interval 8 hour)
            and pi.finished_at < date_add(a1.event_date, interval 16 hour)
        group by 1,2
    ) fin on fin.sys_store_id = a1.sys_store_id and fin.event_date = a1.event_date
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 30 day)
        group by 1
    ) last30 on last30.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi2.sys_store_id
            ,count(distinct mw.id) warn_num
            ,count(distinct mw.staff_info_id) warn_staff_num
        from ph_backyard.message_warning mw
        left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = mw.staff_info_id
        join
            (
                select
                    a1.sys_store_id
                from a a1
                group by 1
            ) a on hsi2.sys_store_id = a.sys_store_id
        where
            mw.created_at >= date_sub(curdate(), interval 7 day)
        group by 1
    ) last7 on last7.sys_store_id = a1.sys_store_id
left join
    (
        select
            hsi.sys_store_id
            ,ss.name
            ,count(distinct if(hsi.state in (1,3) ,hsi.staff_info_id ,null)) + count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月总人数'
            ,count(distinct if(hsi.state = 2 and left(hsi.leave_date ,7) = date_format(date_sub(curdate(), interval 1 month),'%Y-%m') ,hsi.staff_info_id ,null)) '当月离职人数'
        from ph_bi.hr_staff_info hsi
        left join ph_staging.sys_store ss  on ss.id =hsi.sys_store_id
        where
            hsi.formal = 1
            and hsi.is_sub_staff = 0
            and hsi.job_title in (13,110,1000,37)
            and ss.category in (1,10,13,14)
            and hsi.hire_date < date_format(now(), '%y-%m-01')
        group by 1
    ) last_month on last_month.sys_store_id = a1.sys_store_id;
;-- -. . -..- - / . -. - .-. -.--
select
    if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00')) 'Delivered Date 妥投日期'
    ,sr.pno 'Waybill No. 单号'
    ,pi.dst_name 'Customer (收件人)'
    ,pi.dst_phone 'Customer Cellphone No. 手机号'
    ,pi.cod_amount/100 'COD Amount'
    ,ddd.EN_element '包裹状态delivered'
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') POD
from store_receivable_bill_detail sr
left join ph_staging.parcel_info pi on  pi.pno = sr.pno
left join ph_staging.sys_attachment sa on sa.oss_bucket_key = pi.pno and sa.oss_bucket_type = 'DELIVERY_CONFIRM'
left join dwm.dwd_dim_dict ddd on ddd.element = pi.state and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_info' and ddd.fieldname = 'state'
where
    sr.state = 0
    and sr.staff_info_id in ('133254','146507','146757','143787','134193','148916','142398','121760','144652','144492','138797','143495','142149','128073','135027','147435','151353','120282','134656','151595','148602','121659','148946','148349','149051','144575','131258','134845','144366','144343','146323','151317','140410','142190','132084','126623','144641','148384','121392','149245','130896','148566','142116','145596','130649','130339','121302','146462','148864','150014','149339','148927','147045','150756','151484','139759','149005','149160','149422','149265','125254','139477','147707','150007','150642','124716','148765','147318','124057','130589','147006','146775','148979','132906','144479','150134','146884','145894','151111','145504','147550','151111','151744','151869','147960','140839','141022','141220','143711','143986','145193','134890','143686','148895','148325','130290','123024','120890','123557','130728','148627','149421','144016','148769','149932','135558','151743','150210','150911','135137','151913','146703','145201','150387','140685','143706','145755','135323','146846','139555','141434','148845','140317','140766','144719','149153','149407','122852','138395')
group by 2;
;-- -. . -..- - / . -. - .-. -.--
select
    if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00')) 'Delivered Date 妥投日期'
    ,sr.pno 'Waybill No. 单号'
    ,pi.dst_name 'Customer (收件人)'
    ,pi.dst_phone 'Customer Cellphone No. 手机号'
    ,pi.cod_amount/100 'COD Amount'
    ,ddd.EN_element '包裹状态delivered'
    ,sr.staff_info_id 'Courier ID 快递员ID'
    ,hsi.name 'Courier name名字'
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') POD
from store_receivable_bill_detail sr
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = sr.staff_info_id
left join ph_staging.parcel_info pi on  pi.pno = sr.pno
left join ph_staging.sys_attachment sa on sa.oss_bucket_key = pi.pno and sa.oss_bucket_type = 'DELIVERY_CONFIRM'
left join dwm.dwd_dim_dict ddd on ddd.element = pi.state and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_info' and ddd.fieldname = 'state'
where
    sr.state = 0
    and sr.staff_info_id in ('133254','146507','146757','143787','134193','148916','142398','121760','144652','144492','138797','143495','142149','128073','135027','147435','151353','120282','134656','151595','148602','121659','148946','148349','149051','144575','131258','134845','144366','144343','146323','151317','140410','142190','132084','126623','144641','148384','121392','149245','130896','148566','142116','145596','130649','130339','121302','146462','148864','150014','149339','148927','147045','150756','151484','139759','149005','149160','149422','149265','125254','139477','147707','150007','150642','124716','148765','147318','124057','130589','147006','146775','148979','132906','144479','150134','146884','145894','151111','145504','147550','151111','151744','151869','147960','140839','141022','141220','143711','143986','145193','134890','143686','148895','148325','130290','123024','120890','123557','130728','148627','149421','144016','148769','149932','135558','151743','150210','150911','135137','151913','146703','145201','150387','140685','143706','145755','135323','146846','139555','141434','148845','140317','140766','144719','149153','149407','122852','138395')
group by 2;
;-- -. . -..- - / . -. - .-. -.--
select
    if(pi.state = 5, convert_tz(pi.finished_at, '+00:00', '+08:00')) 'Delivered Date 妥投日期'
    ,sr.pno 'Waybill No. 单号'
    ,pi.dst_name 'Customer (收件人)'
    ,pi.dst_phone 'Customer Cellphone No. 手机号'
    ,pi.cod_amount/100 'COD Amount'
    ,ddd.EN_element '包裹状态delivered'
    ,sr.staff_info_id 'Courier ID 快递员ID'
    ,hsi.name 'Courier name名字'
    ,group_concat(concat('https://fex-ph-asset-pro.oss-ap-southeast-1.aliyuncs.com/', sa.object_key) separator ';') POD
from store_receivable_bill_detail sr
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = sr.staff_info_id
left join ph_staging.parcel_info pi on  pi.pno = sr.pno
left join ph_staging.sys_attachment sa on sa.oss_bucket_key = pi.pno and sa.oss_bucket_type = 'DELIVERY_CONFIRM'
left join dwm.dwd_dim_dict ddd on ddd.element = pi.state and ddd.db = 'ph_staging' and ddd.tablename = 'parcel_info' and ddd.fieldname = 'state'
where
    sr.state = 0
    and sr.staff_info_id in ('150911','152334','122227','149610','146846','151913','154223','148312','148003','148864','139759','151307','155096','150296','148384','147707','159856','147045','143711','135266','154511','151309','138920','158577','151526','159845','151484','157717','159478','156449','151595','147691','147432','143686','145201','121732','155492','145449','148895','147654','149005','130589','143787','158697','150642','145203','150549','149477','143986','157118','147097','149245','147561','147652','154777','371173','146775','134193','151027','153092','146774','130649','151317','151467','142939','157690','157956','155152','152857','149407','153054','148602','145193','154824','156276','150014','155346','158096','146507','153624','147318','134656','147776','148831','150007','155182','139055','157185','149352','149863','149265','150347','149160','146703','135558','148927','148946','131258','156827','149847','149421','121659','144719','121392','142116','147350','122852','154346','140976','150387','149998','153480','142069','360705','157393','132084','152100','150002','143108','147960','144016','153836','145324','148448','148566','146389','140839','126623','146179','152025','130339','151353','135102','146757','151622','135323','151738','153886','130896','154923','155094','151260','135027','152483','156378','123024','148325','149113','147006','139100','149932','148349','141022','145504','137819','152021','136061','148099','132906','157152','146556','145894','150756','151668','144641','155667','150769','151804','156306','144479','148268','148720','133871','138253','149051','152156','155748','132752','147550','145488','141434','148627','139555','138797','156353','149289','151672','144914','140317','133912','141220','120890','148765','127779','148709','138395','149551','150034','139303','146462','154448','134890','147539','150187','142136','145273','149527','154085','145755','152319','141076','142398','150210','144047','148619','151869','128053','150606','148317','147847','143267','143495','142058','148769','152254','145116','151756','143706','135428','145932','151114','144652','152015','148729','139171','367544','148294','155419','129548','149623','143806','150134','121302','134845','129368','137955','137267','144343','148979','139258','123557','149984','128073','130290','151164','149339','140685','146884','143265','130728','140766','158123','151343','150421','143081','136330','147714','121760')
group by 2;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pi.pno
        ,pi.state
        ,pi.ticket_pickup_store_id
        ,pi.returned
        ,pi.dst_store_id
        ,pi.client_id
        ,pi.cod_enabled
    from ph_staging.parcel_info pi
    where
        pi.created_at < '2023-06-28 16:00:00'
        and pi.state not in (5,7,8,9)
)
select
    t1.pno
    ,if(t1.returned = 1, '退件', '正向件')  方向
    ,t1.client_id 客户ID
    ,case
        when bc.`client_id` is not null then bc.client_name
        when kp.id is not null and bc.client_id is null then '普通ka'
        when kp.`id` is null then '小c'
    end as 客户类型
    ,case t1.state
        when 1 then '已揽收'
        when 2 then '运输中'
        when 3 then '派送中'
        when 4 then '已滞留'
        when 5 then '已签收'
        when 6 then '疑难件处理中'
        when 7 then '已退件'
        when 8 then '异常关闭'
        when 9 then '已撤销'
    end as 包裹状态
    ,case di.diff_marker_category # 疑难原因
        when 1 then '客户不在家/电话无人接听'
        when 2 then '收件人拒收'
        when 3 then '快件分错网点'
        when 4 then '外包装破损'
        when 5 then '货物破损'
        when 6 then '货物短少'
        when 7 then '货物丢失'
        when 8 then '电话联系不上'
        when 9 then '客户改约时间'
        when 10 then '客户不在'
        when 11 then '客户取消任务'
        when 12 then '无人签收'
        when 13 then '客户周末或假期不收货'
        when 14 then '客户改约时间'
        when 15 then '当日运力不足，无法派送'
        when 16 then '联系不上收件人'
        when 17 then '收件人拒收'
        when 18 then '快件分错网点'
        when 19 then '外包装破损'
        when 20 then '货物破损'
        when 21 then '货物短少'
        when 22 then '货物丢失'
        when 23 then '收件人/地址不清晰或不正确'
        when 24 then '收件地址已废弃或不存在'
        when 25 then '收件人电话号码错误'
        when 26 then 'cod金额不正确'
        when 27 then '无实际包裹'
        when 28 then '已妥投未交接'
        when 29 then '收件人电话号码是空号'
        when 30 then '快件分错网点-地址正确'
        when 31 then '快件分错网点-地址错误'
        when 32 then '禁运品'
        when 33 then '严重破损（丢弃）'
        when 34 then '退件两次尝试派送失败'
        when 35 then '不能打开locker'
        when 36 then 'locker不能使用'
        when 37 then '该地址找不到lockerstation'
        when 38 then '一票多件'
        when 39 then '多次尝试派件失败'
        when 40 then '客户不在家/电话无人接听'
        when 41 then '错过班车时间'
        when 42 then '目的地是偏远地区,留仓待次日派送'
        when 43 then '目的地是岛屿,留仓待次日派送'
        when 44 then '企业/机构当天已下班'
        when 45 then '子母件包裹未全部到达网点'
        when 46 then '不可抗力原因留仓(台风)'
        when 47 then '虚假包裹'
        when 48 then '转交FH包裹留仓'
        when 50 then '客户取消寄件'
        when 51 then '信息录入错误'
        when 52 then '客户取消寄件'
        when 53 then 'lazada仓库拒收'
        when 69 then '禁运品'
        when 70 then '客户改约时间'
        when 71 then '当日运力不足，无法派送'
        when 72 then '客户周末或假期不收货'
        when 73 then '收件人/地址不清晰或不正确'
        when 74 then '收件地址已废弃或不存在'
        when 75 then '收件人电话号码错误'
        when 76 then 'cod金额不正确'
        when 77 then '企业/机构当天已下班'
        when 78 then '收件人电话号码是空号'
        when 79 then '快件分错网点-地址错误'
        when 80 then '客户取消任务'
        when 81 then '重复下单'
        when 82 then '已完成揽件'
        when 83 then '联系不上客户'
        when 84 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 85 then '寄件人电话号码是空号'
        when 86 then '包裹不符合揽收条件超大件'
        when 87 then '包裹不符合揽收条件违禁品'
        when 88 then '寄件人地址为岛屿'
        when 89 then '运力短缺，跟客户协商推迟揽收'
        when 90 then '包裹未准备好推迟揽收'
        when 91 then '包裹包装不符合运输标准'
        when 92 then '客户提供的清单里没有此包裹'
        when 93 then '包裹不符合揽收条件（超大件、违禁物品）'
        when 94 then '客户取消寄件/客户实际不想寄此包裹'
        when 95 then '车辆/人力短缺推迟揽收'
        when 96 then '遗漏揽收(已停用)'
        when 97 then '子母件(一个单号多个包裹)'
        when 98 then '地址错误addresserror'
        when 99 then '包裹不符合揽收条件：超大件'
        when 100 then '包裹不符合揽收条件：违禁品'
        when 101 then '包裹包装不符合运输标准'
        when 102 then '包裹未准备好'
        when 103 then '运力短缺，跟客户协商推迟揽收'
        when 104 then '子母件(一个单号多个包裹)'
        when 105 then '破损包裹'
        when 106 then '空包裹'
        when 107 then '不能打开locker(密码错误)'
        when 108 then 'locker不能使用'
        when 109 then 'locker找不到'
        when 110 then '运单号与实际包裹的单号不一致'
        when 111 then 'box客户取消任务'
        when 112 then '不能打开locker(密码错误)'
        when 113 then 'locker不能使用'
        when 114 then 'locker找不到'
        when 115 then '实际重量尺寸大于客户下单的重量尺寸'
        when 116 then '客户仓库关闭'
        when 117 then '客户仓库关闭'
        when 118 then 'SHOPEE订单系统自动关闭'
        when 119 then '客户取消包裹'
        when 121 then '地址错误'
        when 122 then '当日运力不足，无法揽收'
    end as 疑难原因
#     ,case
#         when t1.state = 6 and di.pno is not null then 'KAM/揽件网点未协商'
#         when t1.state = 6 and di.pno is null  then '闪速系统沟通处理中'
#         when t1.state != 6 and plt.pno is not null and plt2.pno is not null then '闪速系统沟通处理中'
#         when plt.pno is null and pct.pno is not null then '闪速超时效理赔未完成'
#         when de.last_store_id = t1.ticket_pickup_store_id and plt2.pno is null then '揽件未发出'
#         when t1.dst_store_id = 'PH19040F05' and plt2.pno is null then '弃件未到拍卖仓'
#         when t1.state != 6 and datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) > 7 and plt2.pno is not null then 'QAQC无须追责后长期无有效路由'
#         else null
#     end 卡点原因
#     ,de.last_store_name 当前节点
    ,datediff(now(), convert_tz(pr.routed_at, '+00:00', '+08:00')) 最后有效路由距今天数
#     ,de.last_cn_route_action 最新一条有效路由
    ,case pr.route_action # 路由动作
         when 'ACCEPT_PARCEL' then '接件扫描'
         when 'ARRIVAL_GOODS_VAN_CHECK_SCAN' then '车货关联到港'
         when 'ARRIVAL_WAREHOUSE_SCAN' then '到件入仓扫描'
         when 'CANCEL_ARRIVAL_WAREHOUSE_SCAN' then '取消到件入仓扫描'
         when 'CANCEL_PARCEL' then '撤销包裹'
         when 'CANCEL_SHIPMENT_WAREHOUSE' then '取消发件出仓'
         when 'CHANGE_PARCEL_CANCEL' then '修改包裹为撤销'
         when 'CHANGE_PARCEL_CLOSE' then '修改包裹为异常关闭'
         when 'CHANGE_PARCEL_IN_TRANSIT' then '修改包裹为运输中'
         when 'CHANGE_PARCEL_INFO' then '修改包裹信息'
         when 'CHANGE_PARCEL_SIGNED' then '修改包裹为签收'
         when 'CLAIMS_CLOSE' then '理赔关闭'
         when 'CLAIMS_COMPLETE' then '理赔完成'
         when 'CLAIMS_CONTACT' then '已联系客户'
         when 'CLAIMS_TRANSFER_CS' then '转交总部cs处理'
         when 'CLOSE_ORDER' then '关闭订单'
         when 'CONTINUE_TRANSPORT' then '疑难件继续配送'
         when 'CREATE_WORK_ORDER' then '创建工单'
         when 'CUSTOMER_CHANGE_PARCEL_INFO' then '客户修改包裹信息'
         when 'CUSTOMER_OPERATING_RETURN' then '客户操作退回寄件人'
         when 'DELIVERY_CONFIRM' then '确认妥投'
         when 'DELIVERY_MARKER' then '派件标记'
         when 'DELIVERY_PICKUP_STORE_SCAN' then '自提取件扫描'
         when 'DELIVERY_TICKET_CREATION_SCAN' then '交接扫描'
         when 'DELIVERY_TRANSFER' then '派件转单'
         when 'DEPARTURE_GOODS_VAN_CK_SCAN' then '车货关联出港'
         when 'DETAIN_WAREHOUSE' then '货件留仓'
         when 'DIFFICULTY_FINISH_INDEMNITY' then '疑难件支付赔偿'
         when 'DIFFICULTY_HANDOVER' then '疑难件交接'
         when 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE' then '疑难件交接货件留仓'
         when 'DIFFICULTY_RE_TRANSIT' then '疑难件退回区域总部/重启运送'
         when 'DIFFICULTY_RETURN' then '疑难件退回寄件人'
         when 'DIFFICULTY_SEAL' then '集包异常'
         when 'DISCARD_RETURN_BKK' then '丢弃包裹的，换单后寄回BKK'
         when 'DISTRIBUTION_INVENTORY' then '分拨盘库'
         when 'DWS_WEIGHT_IMAGE' then 'DWS复秤照片'
         when 'EXCHANGE_PARCEL' then '换货'
         when 'FAKE_CANCEL_HANDLE' then '虚假撤销判责'
         when 'FLASH_HOME_SCAN' then 'FH交接扫描'
         when 'FORCE_TAKE_PHOTO' then '强制拍照路由'
         when 'HAVE_HAIR_SCAN_NO_TO' then '有发无到'
         when 'HURRY_PARCEL' then '催单'
         when 'INCOMING_CALL' then '来电接听'
         when 'INTERRUPT_PARCEL_AND_RETURN' then '中断运输并退回'
         when 'INVENTORY' then '盘库'
         when 'LOSE_PARCEL_TEAM_OPERATION' then '丢失件团队处理'
         when 'MANUAL_REMARK' then '添加备注'
         when 'MISS_PICKUP_HANDLE' then '漏包裹揽收判责'
         when 'MISSING_PARCEL_SCAN' then '丢失件包裹操作'
         when 'NOTICE_LOST_PARTS_TEAM' then '已通知丢失件团队'
         when 'PARCEL_HEADLESS_CLAIMED' then '无头件包裹已认领'
         when 'PARCEL_HEADLESS_PRINTED' then '无头件包裹已打单'
         when 'PENDING_RETURN' then '待退件'
         when 'PHONE' then '电话联系'
         when 'PICK_UP_STORE' then '待自提取件'
         when 'PICKUP_RETURN_RECEIPT' then '签回单揽收'
         when 'PRINTING' then '打印面单'
         when 'QAQC_OPERATION' then 'QAQC判责'
         when 'RECEIVE_WAREHOUSE_SCAN' then '收件入仓'
         when 'RECEIVED' then '已揽收,初始化动作，实际情况并没有作用'
         when 'REFUND_CONFIRM' then '退件妥投'
         when 'REPAIRED' then '上报问题修复路由'
         when 'REPLACE_PNO' then '换单'
         when 'REPLY_WORK_ORDER' then '回复工单'
         when 'REVISION_TIME' then '改约时间'
         when 'SEAL' then '集包'
         when 'SEAL_NUMBER_CHANGE' then '集包件数变化'
         when 'SHIPMENT_WAREHOUSE_SCAN' then '发件出仓扫描'
         when 'SORTER_WEIGHT_IMAGE' then '分拣机复秤照片'
         when 'SORTING_SCAN' then '分拣扫描'
         when 'STAFF_INFO_UPDATE_WEIGHT' then '快递员修改重量'
         when 'STORE_KEEPER_UPDATE_WEIGHT' then '仓管员复秤'
         when 'STORE_SORTER_UPDATE_WEIGHT' then '分拣机复秤'
         when 'SYSTEM_AUTO_RETURN' then '系统自动退件'
         when 'TAKE_PHOTO' then '异常打单拍照'
         when 'THIRD_EXPRESS_ROUTE' then '第三方公司路由'
         when 'THIRD_PARTY_REASON_DETAIN' then '第三方原因滞留'
         when 'TICKET_WEIGHT_IMAGE' then '揽收称重照片'
         when 'TRANSFER_LOST_PARTS_TEAM' then '已转交丢失件团队'
         when 'TRANSFER_QAQC' then '转交QAQC处理'
         when 'UNSEAL' then '拆包'
         when 'UNSEAL_NO_PARCEL' then '上报包裹不在集包里'
         when 'UNSEAL_NOT_SCANNED' then '集包已拆包，本包裹未被扫描'
         when 'VEHICLE_ACCIDENT_REG' then '车辆车祸登记'
         when 'VEHICLE_ACCIDENT_REGISTRATION' then '车辆车祸登记'
         when 'VEHICLE_WET_DAMAGE_REG' then '车辆湿损登记'
         when 'VEHICLE_WET_DAMAGE_REGISTRATION' then '车辆湿损登记'
        end as 最后一条路由
    ,pr.store_name 最后有效路由动作网点
    ,convert_tz(pr.routed_at ,'+00:00', '+08:00') 最新一条有效路由时间
    ,datediff(now(), de.dst_routed_at) 目的地网点停留时间
    ,de.dst_store 目的地网点
    ,de.src_store 揽收网点
    ,de.pickup_time 揽收时间
    ,de.pick_date 揽收日期
    ,if(hold.pno is not null, 'yes', 'no' ) 是否有holding标记
    ,if(pr3.pno is not null, 'yes', 'no') 是否有待退件标记
    ,td.try_num 尝试派送次数
from t t1
left join ph_staging.ka_profile kp on t1.client_id = kp.id
left join dwm.dwd_dim_bigClient bc on bc.client_id = t1.client_id
left join dwm.dwd_ex_ph_parcel_details de on de.pno = t1.pno
left join
    (
        select
            plt.pno
            ,group_concat(ss.name ) should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        left join ph_bi.work_order wo on wo.loseparcel_task_id = plt.id
        left join ph_staging.sys_store ss on ss.id = wo.store_id
        where
            plt.state in (3)
            and wo.status in (1,2)
        group by 1

        union  all

        select
            plt.pno
            ,'QAQC' should_do
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state in (1,2,4)
    ) plt on plt.pno = t1.pno
left join
    (
        select
            t2.pno
            ,cdt.negotiation_result_category
            ,di.diff_marker_category
            ,case
                when di.diff_marker_category in (20,21)  and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 1 then 'KAM'
                when di.diff_marker_category not in (20,21) and cdt.vip_enable = 0 then ss2.name
                WHEN di.diff_marker_category in (20,21) and cdt.vip_enable = 0 then ss2.name
            end sh_do
        from ph_staging.diff_info di
        join t t2 on t2.pno = di.pno
        join ph_staging.customer_diff_ticket cdt on cdt.diff_info_id = di.id
        left join ph_bi.parcel_lose_task plt on plt.source_id = cdt.id
        left join ph_staging.sys_store ss2 on ss2.id = t2.ticket_pickup_store_id
        where
            cdt.negotiation_result_category is null
    ) di on di.pno = t1.pno
left join  
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.routed_at
            ,pr.route_action
            ,row_number() over (partition by pr.pno order by pr.routed_at desc ) rk
        from  ph_staging.parcel_route pr
        join t t3 on t3.pno = pr.pno
        where
            pr.route_action in ('INVENTORY','RECEIVED' ,'RECEIVE_WAREHOUSE_SCAN', 'SORTING_SCAN', 'DELIVERY_TICKET_CREATION_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SHIPMENT_WAREHOUSE_SCAN', 'DETAIN_WAREHOUSE', 'DELIVERY_CONFIRM', 'DIFFICULTY_HANDOVER', 'DELIVERY_MARKER', 'REPLACE_PNO','SEAL', 'UNSEAL', 'STAFF_INFO_UPDATE_WEIGHT', 'STORE_KEEPER_UPDATE_WEIGHT', 'STORE_SORTER_UPDATE_WEIGHT', 'DISCARD_RETURN_BKK', 'DELIVERY_TRANSFER', 'PICKUP_RETURN_RECEIPT', 'FLASH_HOME_SCAN', 'ARRIVAL_WAREHOUSE_SCAN', 'SORTING_SCAN ', 'DELIVERY_PICKUP_STORE_SCAN', 'DIFFICULTY_HANDOVER_DETAIN_WAREHOUSE', 'REFUND_CONFIRM', 'ACCEPT_PARCEL')
            and pr.organization_type = 1
        ) pr on pr.pno = t1.pno and pr.rk = 1
left join
    (
        select
            plt.pno
        from ph_bi.parcel_lose_task plt
        join t t1 on t1.pno = plt.pno
        where
            plt.state = 5
            and plt.operator_id not in (10000,10001,10002)
        group by 1
    ) plt2 on plt2.pno = t1.pno
left join
    (
        select
            plt.pno
        from ph_bi.parcel_claim_task plt
        join t t4  on t4.pno = plt.pno
        where
            plt.state not in (6,7,8)
            and plt.source = 11
        group by 1
    ) pct on pct.pno = t1.pno
left join
    (
        select
            pr2.pno
        from ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.route_action = 'REFUND_CONFIRM'
        group by 1
    ) hold on hold.pno = t1.pno
left join
    (
        select
            pr2.pno
        from  ph_staging.parcel_route pr2
        join t t1 on t1.pno = pr2.pno
        where
            pr2.route_action = 'PENDING_RETURN'
        group by 1
    ) pr3 on pr3.pno = t1.pno
left join
    (
        select
            td.pno
            ,count(distinct date(convert_tz(tdm.created_at, '+00:00', '+08:00'))) try_num
        from ph_staging.ticket_delivery td
        join t t1 on t1.pno = td.pno
        left join ph_staging.ticket_delivery_marker tdm on tdm.delivery_id = td.id
        group by 1
    ) td on td.pno = t1.pno
group by t1.pno;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        pr.store_id
        ,pr.pno
        ,pr.staff_info_id
        ,pi.state
    from ph_staging.parcel_route pr
    left join ph_staging.parcel_info pi on pi.pno = pr.pno
    where
        pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
        and pr.routed_at >= date_sub(curdate(), interval 8 hour )
        and pr.routed_at < date_add(curdate(), interval 16 hour)
    group by 1,2,3
)
select
    dr.store_id 网点ID
    ,dr.store_name 网点
    ,dr.opening_at 开业时间
    ,case dr.store_category
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
    ,dr.piece_name 片区
    ,dr.region_name 大区
    ,emp_cnt.staf_num 总快递员人数
    ,att.atd_emp_cnt 总出勤快递员人数
    ,a3.sc_num/att.atd_emp_cnt 平均交接量
    ,a3.del_num/att.atd_emp_cnt 平均妥投量
    ,a2.avg_staff_code 三段码平均交接量
    ,a2.avg_staff_del_code 三段码平均妥投量
    ,a2.avg_code_staff 三段码平均交接快递员数
    ,case
        when a2.avg_code_staff < 2 then 'A'
        when a2.avg_code_staff >= 2 and a2.avg_code_staff < 3 then 'B'
        when a2.avg_code_staff >= 3 and a2.avg_code_staff < 4 then 'C'
        when a2.avg_code_staff >= 4 then 'D'
    end 评级
#     ,a2.code_num
#     ,a2.staff_code_num
#     ,a2.staff_num
#     ,a2.fin_staff_code_num
from
    (
        select
            a1.store_id
            ,count(distinct a1.staff_code) staff_code_num
            ,count(distinct a1.third_sorting_code) code_num
            ,count(distinct a1.staff_info_id) staff_num
            ,count(distinct if(a1.state = 5, a1.staff_code, null)) fin_staff_code_num
            ,count(distinct a1.staff_code)/ count(distinct a1.third_sorting_code) avg_code_staff
            ,count(distinct a1.staff_code)/count(distinct a1.staff_info_id)  avg_staff_code
            ,count(distinct if(a1.state = 5, a1.staff_code, null))/count(distinct a1.staff_info_id) avg_staff_del_code
        from
            (
                select
                    a1.*
                    ,concat(a1.staff_info_id, a1.third_sorting_code) staff_code
                from
                    (
                        select
                            t1.store_id
                            ,t1.pno
                            ,t1.staff_info_id
                            ,t1.state
                            ,ps.third_sorting_code
                            ,row_number() over (partition by t1.pno order by ps.created_at desc) rk
                        from t t1
                        left join ph_drds.parcel_sorting_code_info ps on ps.dst_store_id = t1.store_id and ps.pno = t1.pno
                    ) a1
                where
                    a1.rk = 1
            ) a1
        left join ph_staging.parcel_info pi on pi.pno = a1.pno
        group by 1
    ) a2
left join
    (
        select
            hr.sys_store_id
            ,count(distinct hr.staff_info_id) staf_num
        from  ph_bi.hr_staff_info  hr
        where
            hr.formal = 1
            and hr.is_sub_staff= 0
            and hr.job_title in (13,110,1000)
        group by 1
    ) emp_cnt on emp_cnt.sys_store_id = a2.store_id
left join
    (
        select
           ad.sys_store_id
           ,count(distinct ad.staff_info_id) as atd_emp_cnt -- 出勤人数
       from ph_bi.attendance_data_v2 ad
       left join ph_bi.hr_staff_info hr on hr.staff_info_id =ad.staff_info_id
       where
           (ad.attendance_started_at is not null or ad.attendance_end_at is not null)
            and hr.job_title in (13,110,1000)
            and ad.stat_date = curdate()
       group by 1
    ) att on att.sys_store_id = a2.store_id
left join dwm.dim_ph_sys_store_rd dr on dr.store_id = a2.store_id and dr.stat_date = date_sub(curdate(), interval 1 day)
left join
    (
        select
            t1.store_id
            ,count(t1.pno) sc_num
            ,count(if(t1.state = 5, t1.pno, null)) del_num
        from t t1
        group by 1
    ) a3  on a3.store_id = a2.store_id;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id 工号
    ,dp.store_name 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,case
        when hsi2.job_title in (13,110,1000) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end 角色
    ,st.late_num 迟到次数
    ,st.absence_sum 缺勤数据
    ,case
        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3  then 'C'
        else 'B'
    end 出勤评级
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id 工号
    ,if(hsi2.sys_store_id = '-1', 'Head office', dp.store_name) 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,case
        when hsi2.job_title in (13,110,1000) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end 角色
    ,st.late_num 迟到次数
    ,st.absence_sum 缺勤数据
    ,case
        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3  then 'C'
        else 'B'
    end 出勤评级
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id 工号
    ,if(hsi2.sys_store_id = '-1', 'Head office', dp.store_name) 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,case
        when hsi2.job_title in (13,110,1000) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end 角色
    ,st.late_num 迟到次数
    ,st.absence_sum 缺勤数据
    ,st.late_time_sum 迟到时长
    ,case
        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3  then 'C'
        else 'B'
    end 出勤评级
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)

select

    dp.region_name 大区
    ,count(if(hsi2.job_title in (13,110,1000), st.staff_info_id, null)) 出勤人次_快递员
    ,count(if(hsi2.job_title in (13,110,1000) and st.late_or_not = 'y', st.staff_info_id, null)) 迟到人次_快递员
    ,count(if(hsi2.job_title in (13,110,1000) and st.absence_time > 0, st.staff_info_id, null)) 缺勤人次_快递员
    ,count(if(hsi2.job_title in (13,110,1000) and st.late_or_not = 'y', st.staff_info_id, null))/count(if(hsi2.job_title in (13,110,1000), st.staff_info_id, null)) 迟到占比_快递员
    ,count(if(hsi2.job_title in (13,110,1000) and st.absence_time > 0, st.staff_info_id, null))/count(if(hsi2.job_title in (13,110,1000), st.staff_info_id, null)) 缺勤占比_快递员

    ,count(if(hsi2.job_title in (37), st.staff_info_id, null)) 出勤人次_仓管
    ,count(if(hsi2.job_title in (37) and st.late_or_not = 'y', st.staff_info_id, null)) 迟到人次_仓管
    ,count(if(hsi2.job_title in (37) and st.absence_time > 0, st.staff_info_id, null)) 缺勤人次_仓管
    ,count(if(hsi2.job_title in (37) and st.late_or_not = 'y', st.staff_info_id, null))/count(if(hsi2.job_title in (37), st.staff_info_id, null)) 迟到占比_仓管
    ,count(if(hsi2.job_title in (37) and st.absence_time > 0, st.staff_info_id, null))/count(if(hsi2.job_title in (37), st.staff_info_id, null)) 缺勤占比_仓管

    ,count(if(hsi2.job_title in (16), st.staff_info_id, null)) 出勤人次_主管
    ,count(if(hsi2.job_title in (16) and st.late_or_not = 'y', st.staff_info_id, null)) 迟到人次_主管
    ,count(if(hsi2.job_title in (16) and st.absence_time > 0, st.staff_info_id, null)) 缺勤人次_主管
    ,count(if(hsi2.job_title in (16) and st.late_or_not = 'y', st.staff_info_id, null))/count(if(hsi2.job_title in (16), st.staff_info_id, null)) 迟到占比_主管
    ,count(if(hsi2.job_title in (16) and st.absence_time > 0, st.staff_info_id, null))/count(if(hsi2.job_title in (16), st.staff_info_id, null)) 缺勤占比_主管
from
    (
        select
            a.*
        from
            (
                select
                    t1.*
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                    ,t1.AB/10 absence_time
                from t t1
            ) a
    ) st
left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
group by 1
with rollup;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
                        and hsi.hire_date <= date_sub(curdate(), interval 7 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    st.staff_info_id 工号
    ,if(hsi2.sys_store_id = '-1', 'Head office', dp.store_name) 网点
    ,dp.piece_name 片区
    ,dp.region_name 大区
    ,case
        when hsi2.job_title in (13,110,1000) then '快递员'
        when hsi2.job_title in (37) then '仓管员'
        when hsi2.job_title in (16) then '主管'
    end 角色
    ,st.late_num 迟到次数
    ,st.absence_sum 缺勤数据
    ,st.late_time_sum 迟到时长
    ,case
        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
        when st.absence_sum >= 2 or st.late_num >= 3  then 'C'
        else 'B'
    end 出勤评级
from
    (
        select
            a.staff_info_id
            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
            ,sum(a.absence_time) absence_sum
        from
            (
                select
                    t1.*
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                    ,t1.AB/10 absence_time
                from t t1
            ) a
        group by 1
    ) st
left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
order by 2,1;
;-- -. . -..- - / . -. - .-. -.--
with t as
(
    select
        *
    from
        (
            select
                ad.*
                ,row_number() over (partition by ad.staff_info_id order by ad.stat_date desc) rk
            from
                (
                    select
                        ad.*
                        ,ad.attendance_time + ad.BT + ad.CT + ad.BT_Y + ad.AB total
                    from ph_bi.attendance_data_v2 ad
                    join ph_bi.hr_staff_info hsi on hsi.staff_info_id = ad.staff_info_id and hsi.state = 1 and hsi.wait_leave_state = 0 and hsi.job_title in (13,110,1000,37,16) -- 在职且非待离职
                    where
                        ad.stat_date < curdate()
                        and hsi.hire_date <= date_sub(curdate(), interval 7 day )
#                         and ad.stat_date >= date_sub(curdate(), interval 30 day )
                ) ad
            where
                ad.total = 10
        ) ad
    where
        ad.rk < 8
)
select
    ss.store_id 网点ID
    ,dp.store_name 网点
    ,dp.opening_at 开业时间
    ,case dp.store_category
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
    ,dp.region_name 大区
    ,dp.piece_name 片区
    ,ss.num/dp.on_emp_cnt C级员工占比
    ,ss.num C级快递员
    ,dp.on_emp_cnt 在职员工数
    ,case
        when ss.num/dp.on_emp_cnt < 0.05 then 'A'
        when ss.num/dp.on_emp_cnt >= 0.05 and ss.num/dp.on_emp_cnt < 0.1 then 'B'
        when ss.num/dp.on_emp_cnt >= 0.1 then 'C'
    end store_level
    ,ss.avg_absence_num 近7天缺勤人次
    ,ss.avg_absence_num/7 近7天平均每天缺勤人次
    ,ss.avg_late_num 近7天人均迟到人次
    ,ss.avg_late_num/7 近7天平均每天迟到人次
from
    (
        select
            s.store_id
            ,count(if(s.ss_level = 'C', s.staff_info_id, null)) num
            ,sum(s.late_num) avg_late_num
            ,sum(s.absence_sum) avg_absence_num
        from
            (
                select
                    st.staff_info_id
                    ,dp.store_id
                    ,dp.store_name
                    ,dp.piece_name
                    ,dp.region_name
                    ,case
                        when hsi2.job_title in (13,110,1000) then '快递员'
                        when hsi2.job_title in (37) then '仓管员'
                        when hsi2.job_title in (16) then '主管'
                    end roles
                    ,st.late_num
                    ,st.absence_sum
                    ,case
                        when st.absence_sum = 0 and st.late_num <= 1 and st.late_time_sum < 30 then 'A'
                        when st.absence_sum >= 2 or st.late_num >= 3 then 'C'
                        else 'B'
                    end ss_level
                from
                    (
                        select
                            a.staff_info_id
                            ,count(if(a.late_or_not = 'y' ,a.stat_date, null)) late_num
#                             ,count(if(a.early_or_not = 'y', a.stat_date, null)) early_num
                            ,sum(if(a.late_or_not = 'y', a.late_time, 0)) late_time_sum
#                             ,sum(if(a.early_or_not = 'y', a.early_yime, 0)) early_time_sum
                            ,sum(a.absence_time) absence_sum
                        from
                            (
                                select
                                    t1.*
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , 'y', 'n') late_or_not
                                    ,if(date_format(t1.attendance_started_at, '%H:%i') > t1.shift_start , timestampdiff(second, t1.shift_start, t1.attendance_started_at)/60, 0) late_time
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, 'y', 'n' ) early_or_not
#                                     ,if(date_format(t1.attendance_end_at, '%H:%i') < t1.shift_end, timestampdiff(second, t1.attendance_end_at, t1.shift_end)/60, 0) early_yime
                                    ,t1.AB/10 absence_time
                                from t t1
                            ) a
                        group by 1
                    ) st
                left join ph_bi.hr_staff_info hsi2 on hsi2.staff_info_id = st.staff_info_id
                left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi2.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
            ) s
        group by 1
    ) ss
left join dwm.dwm_ph_network_wide_s dp on dp.store_id = ss.store_id and dp.stat_date = date_sub(curdate(), interval 1 day)
where
    dp.on_emp_cnt > 0
    and dp.store_category = 1;