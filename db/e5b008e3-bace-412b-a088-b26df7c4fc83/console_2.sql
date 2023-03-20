select
    *
from ph_staging.parcel_headless ph
where
    ph.created_at >= '2021-12-31 16:00:00'
;
select
    t.*
    ,ss.name
from tmpale.tmp_ph_1_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id;

select
    t.month_d 月份
    ,sum(t.count_num) 总访问次数
    ,sum(if(ss.category in (1,10), t.count_num, 0 ))/sum(t.count_num) SP_BDC占比
    ,sum(if(ss.category in (8,12), t.count_num, 0 ))/sum(t.count_num) hub占比
#     ,sum(t.count_num)/count(distinct t.staff_info) 网点平均访问次数
#     ,count(distinct t.staff_info) 访问员工数
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    t.count_num > 2
#     and ss.category in (8,12)
group by 1
;

select
    t.month_d 月份
#     ,sum(t.count_num) 总访问次数
#     ,sum(if(ss.category in (1,10), t.count_num, 0 ))/sum(t.count_num) SP_BDC占比
#     ,sum(if(ss.category in (8,12), t.count_num, 0 ))/sum(t.count_num) hub占比
     ,ss.name
    ,sum(t.count_num)/count(distinct t.staff_info) 网点每人平均访问次数
    ,sum(t.count_num) 总访问
    ,count(distinct t.staff_info) 访问员工数
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
where
    t.count_num > 2
    and ss.category in (8,12)
group by 1,2
;

select
    a.*
    ,b.总访问_认领
    ,b.网点每人平均访问次数_认领
    ,b.访问员工数_认领
from
    (
        select
            t.month_d
            ,ss.name
            ,sum(t.count_num)/count(distinct t.staff_info) 网点每人平均访问次数_hub
            ,sum(t.count_num) 总访问_hub
            ,count(distinct t.staff_info) 访问员工数_hub
        from tmpale.tmp_ph_hub_0318 t
        left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
        left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
#         left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
        where
            ss.category in (8,12)
#             and ss.name = '11 PN5-HUB_Santa Rosa'
            and t.count_num > 2
        group by 1,2
    ) a
left join
    (
         select
            t.month_d
            ,ss.name
            ,sum(t._col1)/count(distinct t. c_sid_ms) 网点每人平均访问次数_认领
            ,sum(t._col1) 总访问_认领
            ,count(distinct t. c_sid_ms) 访问员工数_认领
        from tmpale.tmp_ph_renlin_0318  t
        left join ph_bi.hr_staff_info hsi on t.c_sid_ms = hsi.staff_info_id
        left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
#         left join ph_staging.sys_department sd on sd.id = hsi.sys_department_id
        where
            ss.category in (8,12)
#             and ss.name = '11 PN5-HUB_Santa Rosa'
            and t._col1 > 2
        group by 1,2
    )  b on a.month_d = b.month_d and a.name = b.name
;
select
    t.month_d 月份
    ,ss.name 网点
    ,t.staff_info
    ,t.count_num 次数
from tmpale.tmp_ph_hub_0318 t
left join ph_bi.hr_staff_info hsi on t.staff_info = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    t.count_num > 10
    and ss.id is not null
;
select
    t.month_d 月份
    ,ss.name 网点
    ,t.c_sid_ms
    ,t._col1 次数
from tmpale.tmp_ph_renlin_0318 t
left join ph_bi.hr_staff_info hsi on t.c_sid_ms = hsi.staff_info_id
left join ph_staging.sys_store ss on ss.id = hsi.sys_store_id
where
    t._col1 > 10
    and ss.id is not null