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
;

select
    a.staff_info_id
from
    (

        select
            a.*
        from
            (
                select
                    mw.staff_info_id
                    ,mw.id
                    ,mw.created_at
                    ,count(mw.id) over (partition by mw.staff_info_id) js_num
                    ,row_number() over (partition by mw.staff_info_id order by mw.created_at desc) rn
                from ph_backyard.message_warning mw
            ) a
        where
            a.rn = 1
    ) a
left join ph_bi.hr_staff_info hsi on hsi.staff_info_id = a.staff_info_id
where
    a.js_num >= 3
    and a.created_at < '2023-01-01'
    and hsi.state = 1
group by 1
;

select
     pr.`store_id` 网点ID
    ,ss.name 网点
    ,pr.pno 包裹

from `ph_staging`.`parcel_route` pr
left join `ph_staging`.`parcel_info` pi on pi.pno=pr.`pno`
left join ph_staging.sys_store ss on ss.id = pr.store_id
where
    pr.`route_action` in ('SHIPMENT_WAREHOUSE_SCAN')
    and date_format(convert_tz(pr.`routed_at`, '+00:00', '+08:00'),'%y-%m-%d')=date_sub(curdate(),interval 1 day)
    and pi.`exhibition_weight`<=3000
    and (pi.`exhibition_length` +pi.`exhibition_width` +pi.`exhibition_height`)<=60
    and pi.`exhibition_length` <=30
    and pi.`exhibition_width` <=30
    and pi.`exhibition_height` <=30
#     and ss.category in (8,12)
#     and ss.state = 1
group by 1,2,3
;
select date_sub(curdate(),interval 1 day)
;

select
    mw.staff_info_id 员工ID
    ,mw.id 警告信ID
    ,mw.created_at 警告信创建时间
    ,mw.is_delete 是否删除
    ,case mw.type_code
        when 'warning_1'  then '迟到早退'
        when 'warning_29' then '贪污包裹'
        when 'warning_30' then '偷盗公司财物'
        when 'warning_11' then '吵架、打架/伤害同事、外部人员、上级或其他'
        when 'warning_9'  then '腐败/滥用职权'
        when 'warning_8'  then '公司设备私人使用 / 利用公司设备去做其他事情'
        when 'warning_5'  then '持有或吸食毒品'
        when 'warning_4'  then '工作时间或工作地点饮酒'
        when 'warning_10' then '玩忽职守'
        when 'warning_2'  then '无故连续旷工3天'
        when 'warning_3'  then '贪污'
        when 'warning_6'  then '违反公司的命令/通知/规则/纪律/规定'
        when 'warning_7'  then '通过社会媒体污蔑公司'
        when 'warning_27' then '工作效率未达到公司的标准(KPI)'
        when 'warning_26' then 'Fake POD'
        when 'warning_25' then 'Fake Status'
        when 'warning_24' then '不接受或不配合公司的调查'
        when 'warning_23' then '损害公司名誉'
        when 'warning_22' then '失职'
        when 'warning_28' then '贪污钱'
        when 'warning_21' then '煽动/挑衅/损害公司利益'
        when 'warning_20' then '谎报里程'
        when 'warning_18' then '粗心大意造成公司重大损失（造成钱丢失）'
        when 'warning_19' then '未按照网点规定的时间回款'
        when 'warning_17' then '伪造证件'
        when 'warning_12' then '未告知上级或无故旷工'
        when 'warning_13' then '上级没有同意请假'
        when 'warning_14' then '没有通过系统请假'
        when 'warning_15' then '未按时上下班'
        when 'warning_16' then '不配合公司的吸毒检查'
        when 'warning_06' then '违反公司的命令/通知/规则/纪律/规定'
        else mw.`type_code`
    end as '警告原因'
from ph_backyard.message_warning mw
where
    mw.staff_info_id in ('119872', '124880', '119279', '119022', '118822', '118925', '120282', '130832', '120267', '123336', '119617', '146865')