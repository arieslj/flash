
select
    t.*
    ,vrv.link_id
from tmpale.tmp_ph_ivr_datail_1205 t
left join nl_production.violation_return_visit vrv on vrv.id = t.taskid
;


select
    vrv.link_id
    ,vrv.id
    ,vrv.visit_state
    ,vrv.created_at
from nl_production.violation_return_visit vrv
where
    vrv.link_id in ('PT210224ZQFY0AD','PT261724ZHWJ2BE','PT422124ZARH5AU','PT261024YKJE5AO','PT421024XPA69AD','PT430624YUAD5AK','PT182224YMN10AK','PT420224ZHTX7BD','PT790624XWFC9AN','PT411324XSV66AV','PT400124ZJ4K2AW','PT0221250WBJ0AE','PT430924X2JV4AE','PT090324YMM86AB','PT770324X2PQ1AH','PT261224YCQR4AY','PT400324WTUE4AK','PT401624YDW62AT','PT09032513UY1AK','PT023424ZDFW9AF','PT22012502NT2AD','PT070824YZE52BZ','PT070724X74J5AN')
     and vrv.visit_staff_id  = 10001 OR ( vrv.visit_staff_id = 0 AND vrv.visit_state = 2 )
    and vrv.type  = 3
;

select
    t.pno
    ,case pi.state
        when 1 then 'RECEIVED'
        when 2 then 'IN_TRANSIT'
        when 3 then 'DELIVERING'
        when 4 then 'STRANDED'
        when 5 then 'SIGNED'
        when 6 then 'IN_DIFFICULTY'
        when 7 then 'RETURNED'
        when 8 then 'ABNORMAL_CLOSED'
        when 9 then 'CANCEL'
    end as parcel_tatus
from ph_staging.parcel_info pi
join tmpale.tmp_ph_pno_lj_1212  t on t.pno = pi.pno

;

select
    a1.pno
    ,a1.sub_time
    ,a1.store_name
    ,a2.di_cnt
    ,pi.dst_detail_address
from
    (
        select
            pr.pno
            ,pr.store_name
            ,pr.store_id
            ,pr.routed_at
            ,pr.staff_info_id
            ,t.sub_time
        from ph_staging.parcel_route pr
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = pr.pno and t.satff = pr.staff_info_id and date_format(pr.routed_at, '%Y-%m-%d %H:%i') = date_format(date_sub(t.sub_time, interval 8 hour), '%Y-%m-%d %H:%i')
        where
            pr.routed_at > '2023-12-28'
           -- and t.pno = 'PT351725YGUU0BP'
    ) a1
left join
    (
        select
            di.pno
            ,count(distinct di.id) di_cnt
        from  ph_staging.diff_info di
        join tmpale.tmp_ph_pno_lj_0129 t on t.pno = di.pno
        where
            di.diff_marker_category = 31
            and di.created_at > '2023-09-01'
        group by  1
    ) a2 on a2.pno = a1.pno
left join ph_staging.parcel_info pi on pi.pno = a1.pno




;
