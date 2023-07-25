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
    ) a3  on a3.store_id = a2.store_id