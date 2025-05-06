select
    date(convert_tz(pr.routed_at, '+00:00', '+08:00')) 日期
    ,pr.staff_info_id
    ,pr.staff_info_name
    ,count(distinct pr.pno ) 交接包裹数
from ph_staging.parcel_route pr
where
    pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
    and pr.routed_at > '2023-12-01 16:00:00'
    and pr.staff_info_id in (176377, 152287, 152126, 176468, 160755, 148374, 154455, 175532, 168556, 126836, 148696, 119887, 148571, 122572, 154599, 176381, 176300, 148688, 162345, 175710, 126200, 135034, 176370, 176248, 159308)
group by 1,2,3

;
  /*=====================================================================+
    表名称： 1901d_ph_dco_scan_delivery_monitor
    功能描述： 菲律宾仓管交接妥投数据监控

    需求来源：
    编写人员: 吕杰
    设计日期：2023/12/21
    修改日期:
    修改人员:
    修改原因:
  -----------------------------------------------------------------------
  ---存在问题：
  -----------------------------------------------------------------------
  +=====================================================================*/

  select
    dp.region_name 大区
    ,dp.piece_name 片区
    ,dp.store_name 网点
    ,a1.pr_date 日期
    ,a1.staff_info_id 员工ID
    ,a1.pno_count 交接包裹数
    ,a2.pno_count 妥投包裹数
from
    (
        select
            a.pr_date
            ,a.staff_info_id
            ,count(distinct a.pno) pno_count
        from
            (
                select
                    pr.pno
                    ,pr.staff_info_id
                    ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
                    ,row_number() over (partition by pr.pno, date(convert_tz(pr.routed_at, '+00:00', '+08:00')) order by pr.routed_at desc ) rk
                from ph_staging.parcel_route pr
                where
                    pr.routed_at > '2023-12-24 16:00:00'
#                     and pr.routed_at < date_add(curdate(), interval 8 hour)
                    and pr.route_action = 'DELIVERY_TICKET_CREATION_SCAN'
            ) a
        where
            a.staff_info_id in ('131667','135063','136805','132944','136805','134125','154000','120396','147274','124324','129173','135063','149330','175532','178346','178348','178519','178521','178601','178602','178833','179178','179720','179815','179948','179952','179954','179956','154645','175871','178314','178317','178318','179908','179912','179913','133717','119873','119887','144948','168673','158001','178244','157222','153171','170843','145153')
            and a.rk = 1
        group by 1,2
    ) a1
left join
    (
        select
            pr.staff_info_id
            ,date(convert_tz(pr.routed_at, '+00:00', '+08:00')) pr_date
            ,count(distinct pr.pno) pno_count
        from ph_staging.parcel_route pr
        where
            pr.routed_at > '2023-12-24 16:00:00'
            and pr.route_action = 'DELIVERY_CONFIRM'
            and pr.staff_info_id in ('131667','135063','136805','132944','136805','134125','154000','120396','147274','124324','129173','135063','149330','175532','178346','178348','178519','178521','178601','178602','178833','179178','179720','179815','179948','179952','179954','179956','154645','175871','178314','178317','178318','179908','179912','179913','133717','119873','119887','144948','168673','158001','178244','157222','153171','170843','145153')
        group by 1,2
    ) a2 on a2.staff_info_id = a1.staff_info_id and a2.pr_date = a1.pr_date
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = a1.staff_info_id
# left join ph_backyard.hr_staff_apply_support_store hsa on hsa.staff_info_id = a1.staff_info_id and hsa.status = 2 and hsa.employment_begin_date <= a1.pr_date and hsa.employment_end_date >= a1.pr_date
left join dwm.dim_ph_sys_store_rd dp on dp.store_id = hsi.sys_store_id and dp.stat_date = date_sub(curdate(), interval 1 day )
